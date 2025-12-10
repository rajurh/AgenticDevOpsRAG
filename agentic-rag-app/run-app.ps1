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

# Start backend in background
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    .\.venv\Scripts\uvicorn.exe app:app --host 127.0.0.1 --port 8001
}

Write-Host "✅ Backend API started (Job ID: $($backendJob.Id))" -ForegroundColor Green
Start-Sleep -Seconds 3

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
