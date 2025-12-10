Single-container deployment (backend + frontend in one image)

Overview
--------
This repository can be packaged as a single Docker container that runs:
- FastAPI backend (uvicorn) on internal port 8001
- Streamlit UI on internal port 8501
- nginx listening on port 80 and reverse-proxying:
  - /api → FastAPI
  - / → Streamlit

This is a convenient simplified deployment model for demos and small labs.

Build and run locally
---------------------
# From project root
# 1) Build image

docker build -t agentic-rag-app:local .

# 2) Run container (map port 80)

docker run --rm -p 8080:80 \
  -e AZURE_OPENAI_EMBEDDING_URL="<your_url>" \
  -e AZURE_OPENAI_CHAT_URL="<your_url>" \
  -e AZURE_OPENAI_KEY="<your_key>" \
  agentic-rag-app:local

# Access UI at http://localhost:8080
# API is available at http://localhost:8080/api/query

Notes on environment variables
------------------------------
- Provide Azure OpenAI values via environment variables (App Settings in Azure). Do NOT bake keys into the image.
- You may also provide TOP_K, or any other env var used by the app.

Azure deployment (App Service for Containers)
--------------------------------------------
1) Create resource group and ACR (if you do not have one):

```bash
RESOURCE_GROUP="rg-agentic-rag-app"
LOCATION="eastus"
ACR_NAME="<your-acr-name>"
az group create -n $RESOURCE_GROUP -l $LOCATION
az acr create -g $RESOURCE_GROUP -n $ACR_NAME --sku Basic
```

2) Build & push image to ACR (recommended):

```bash
az acr build -r $ACR_NAME -t agentic-rag-app:latest .
```

3) Create App Service Plan and Web App for Containers

```bash
PLAN="asp-agentic-rag"
WEBAPP="agentic-rag-app"
az appservice plan create -g $RESOURCE_GROUP -n $PLAN --is-linux --sku B1
az webapp create -g $RESOURCE_GROUP -p $PLAN -n $WEBAPP --deployment-container-image-name "$ACR_NAME.azurecr.io/agentic-rag-app:latest"
```

4) Configure container image source and app settings

```bash
az webapp config container set -g $RESOURCE_GROUP -n $WEBAPP \
  --docker-custom-image-name "$ACR_NAME.azurecr.io/agentic-rag-app:latest" \
  --docker-registry-server-url "https://$ACR_NAME.azurecr.io"

# Set environment variables (secrets should be from Key Vault or GitHub secrets)
az webapp config appsettings set -g $RESOURCE_GROUP -n $WEBAPP --settings \
  AZURE_OPENAI_EMBEDDING_URL="<url>" AZURE_OPENAI_CHAT_URL="<url>" AZURE_OPENAI_KEY="<key>" TOP_K=3
```

5) (Optional) Use Azure Key Vault references instead of raw secrets in App Settings.

6) Set health check path in App Service to `/api/health` (if implemented) in the Azure Portal (under Monitoring → Health check).

7) Browse to the App Service URL. The app listens on port 80 and nginx proxies to the internal services.

Considerations & caveats
------------------------
- Single-container is easiest for demos but less flexible in scaling. If you expect heavy load, separate services are recommended.
- Keep secrets out of images. Use Key Vault and managed identity when possible.
- For production, consider using Azure Container Apps or Kubernetes for autoscaling.

Troubleshooting
---------------
- If the UI cannot reach the API, ensure nginx is running and internal uvicorn/streamlit started properly.
- Check logs from the container (`docker logs <container>`) or App Service logs in Azure.
- If binding errors occur, ensure no other process is using the container internal ports.
