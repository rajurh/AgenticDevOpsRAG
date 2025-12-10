#!/usr/bin/env pwsh
# Run both backend and frontend

Write-Host "🚀 Starting Agentic RAG Application..." -ForegroundColor Cyan

# Check if virtual environment exists
if (-not (Test-Path ".venv")) {
    Write-Host "❌ Virtual environment not found. Please run setup.ps1 first" -ForegroundColor Red
    exit 1
}

Write-Host "`n📌 This will start two services:" -ForegroundColor Yellow
Write-Host "   1. Backend API on http://127.0.0.1:8001" -ForegroundColor White
Write-Host "   2. Frontend UI on http://localhost:8501" -ForegroundColor White
Write-Host "`n⚠️  Press Ctrl+C to stop both services`n" -ForegroundColor Yellow

# Free ports if in use (8001 backend, 8501 frontend)
Write-Host "\n🔎 Checking for processes using ports 8001 or 8501..." -ForegroundColor Cyan
$listeners = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.LocalPort -in 8001,8501 } | Select-Object -Unique LocalPort,OwningProcess
if ($listeners) {
    foreach ($l in $listeners) {
        $pid = $l.OwningProcess
        try {
            $proc = Get-Process -Id $pid -ErrorAction Stop
            Write-Host "Stopping process Id=$($proc.Id) Name=$($proc.ProcessName) using port $($l.LocalPort)" -ForegroundColor Yellow
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "Could not stop PID ${pid}: $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "No conflicting listeners found." -ForegroundColor Green
}

# Also stop any residual PowerShell jobs created previously
$jobs = Get-Job -ErrorAction SilentlyContinue
if ($jobs) {
    Write-Host "Stopping background PowerShell jobs..." -ForegroundColor Yellow
    $jobs | Stop-Job -ErrorAction SilentlyContinue
    $jobs | Remove-Job -ErrorAction SilentlyContinue
}

# Start backend in background
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    .\.venv\Scripts\uvicorn.exe app:app --host 127.0.0.1 --port 8001
}

Write-Host "✅ Backend API started (Job ID: $($backendJob.Id))" -ForegroundColor Green
# Wait for backend port to be ready (8001)
$maxWait = 15
$waited = 0
while ($waited -lt $maxWait) {
    $open = Get-NetTCPConnection -LocalPort 8001 -State Listen -ErrorAction SilentlyContinue
    if ($open) { break }
    Start-Sleep -Seconds 1
    $waited += 1
}
if ($waited -ge $maxWait) {
    Write-Host "Warning: backend did not open port 8001 within $maxWait seconds." -ForegroundColor Yellow
} else {
    Write-Host "Backend port 8001 is listening (after $waited seconds)." -ForegroundColor Green
}

# Start frontend in foreground
$env:RAG_BASE = "http://127.0.0.1:8001"
try {
    .\.venv\Scripts\streamlit.exe run streamlit_app.py
} finally {
    Write-Host "`n🛑 Stopping backend API..." -ForegroundColor Yellow
    Stop-Job -Job $backendJob
    Remove-Job -Job $backendJob
    Write-Host "✅ Application stopped" -ForegroundColor Green
}
