# Deploy script for Agentic RAG App using Azure Container Apps and Azure Container Registry# Subscription to use (leave empty to use current account)
$SubscriptionId = <REPLACE_WITH_YOUR_AZURE_SUBSCRIPTION_ID>

# Azure location for Bicep deployment
$Location = 'australiaeast'

# Azure OpenAI settings (set to '' if not using)
$AzureOpenAIKey = <REPLACE_WITH_YOUR_AZURE_OPENAI_KEY>
$AzureOpenAIChatUrl = <REPLACE_WITH_YOUR_AZURE_OPENAI_CHAT_URL>
$AzureOpenAIEmbeddingUrl = <REPLACE_WITH_YOUR_AZURE_OPENAI_EMBEDDING_URL>

# Image tag to build/push
$Tag = 'latest'



function Run-Command($cmd) {
    Write-Host "> $cmd"
    $res = Invoke-Expression $cmd
    return $res
}

if ($SubscriptionId) {
    az account set --subscription $SubscriptionId | Out-Null
}


Write-Host "1) Deploy infra via Bicep (subscription scope)"
$deploy = az deployment sub create --location $Location --template-file infra/main.bicep -o json 2>&1
if ($LASTEXITCODE -ne 0) { Write-Error "Bicep deployment failed:"; Write-Error $deploy; exit 1 }

$outputs = az deployment sub show --name main --query properties.outputs -o json | ConvertFrom-Json
$rgName = $outputs.resourceGroupName.value
$acrName = $outputs.acrName.value
$acrLoginServer = $outputs.acrLoginServer.value
$containerAppName = $outputs.containerAppName.value
$containerAppFqdn = $outputs.containerAppFqdn.value

Write-Host "Deployed RG: $rgName, ACR: $acrName, ContainerApp: $containerAppName"

Write-Host "2) Build and push Docker image to ACR"
az acr login --name $acrName | Out-Null
$tag = $Tag
Write-Host "Building image tag: $tag"
docker build -t $acrLoginServer/agentic-rag-app:$tag .
docker push $acrLoginServer/agentic-rag-app:$tag

Write-Host "3) Configure Container App secrets and registry"
$acrPass = az acr credential show -n $acrName --query "passwords[0].value" -o tsv

# Set container app secrets (ACR password and optional Azure OpenAI key)
$secretArgs = @()
$secretArgs += "acrpassword=`"$acrPass`""
if ($AzureOpenAIKey) { $secretArgs += "azureopenaikey=`"$AzureOpenAIKey`"" }
Write-Host "Setting Container App secrets: $($secretArgs -join ', ')"
az containerapp secret set --resource-group $rgName --name $containerAppName --secrets $secretArgs | Out-Null

# Ensure registries reference ACR with passwordSecretRef
Write-Host "Configuring Container App registries to use ACR and secret reference"
$registriesJson = "[{'server':'$acrLoginServer','username':'$acrName','passwordSecretRef':'acrpassword'}]"
az containerapp update --resource-group $rgName --name $containerAppName --set configuration.registries="$registriesJson" | Out-Null

Write-Host "4) Update Container App image and ensure ingress targetPort matches nginx (8000)"
az containerapp update --resource-group $rgName --name $containerAppName --image $acrLoginServer/agentic-rag-app:$tag | Out-Null
az containerapp update --resource-group $rgName --name $containerAppName --set configuration.ingress.targetPort=8000 | Out-Null

# Optionally apply the provided YAML (useful if you want to commit infra/containerapp-update.yaml as canonical)
if ($UseYaml) {
    Write-Host "Applying infra/containerapp-update.yaml (will use values from that file)"
    az containerapp update --resource-group $rgName --name $containerAppName --yaml infra/containerapp-update.yaml -o json
}

# If Azure OpenAI key or URLs provided, set secret and update container env (simple, no temp files)
if ($AzureOpenAIKey -or $AzureOpenAIChatUrl -or $AzureOpenAIEmbeddingUrl) {
    if ($AzureOpenAIKey) {
        Write-Host "Setting azureopenaikey secret in Container App"
        az containerapp secret set --resource-group $rgName --name $containerAppName --secrets azureopenaikey="$AzureOpenAIKey" | Out-Null
    }

    Write-Host "Setting environment variables in Container App"
    # Build env var arguments using --replace-env-vars (supports both secretref= and plain values)
    $envArgs = @()
    
    if ($AzureOpenAIKey) { $envArgs += "AZURE_OPENAI_KEY=secretref:azureopenaikey" }
    if ($AzureOpenAIChatUrl) { $envArgs += "AZURE_OPENAI_CHAT_URL=$AzureOpenAIChatUrl" }
    if ($AzureOpenAIEmbeddingUrl) { $envArgs += "AZURE_OPENAI_EMBEDDING_URL=$AzureOpenAIEmbeddingUrl" }

    # Apply all env vars in one update
    if ($envArgs.Count -gt 0) {
        az containerapp update --resource-group $rgName --name $containerAppName --replace-env-vars $envArgs | Out-Null
    }
    
    Write-Host "Environment variables configured"
}

Write-Host "Waiting for the Container App to become Running..."
for ($i=0; $i -lt 60; $i++) {
    $ca = az containerapp show --resource-group $rgName --name $containerAppName -o json | ConvertFrom-Json
    if ($ca.properties.runningStatus -eq 'Running' -and $ca.properties.provisioningState -eq 'Succeeded') { break }
    Write-Host "Provisioning state: $($ca.properties.provisioningState) | RunningStatus: $($ca.properties.runningStatus)"
    Start-Sleep -Seconds 5
}

$fqdn = az containerapp show --resource-group $rgName --name $containerAppName --query properties.configuration.ingress.fqdn -o tsv
Write-Host "ContainerApp FQDN: $fqdn"

Write-Host "5) Quick validation: tail logs (last 200 lines) and run a streaming POST"
az containerapp logs show --resource-group $rgName --name $containerAppName --tail 200

Write-Host "Running streaming test against https://$fqdn/api/query"
curl -v -N -H "Accept: text/event-stream" -H "Content-Type: application/json" -X POST "https://$fqdn/api/query" -d '{"query":"test streaming","top_k":3}' --max-time 300

Write-Host "Done. If streaming fails, inspect logs or run the test again while tailing logs."
