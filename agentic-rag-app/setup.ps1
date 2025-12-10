#!/usr/bin/env pwsh
# Setup script for Agentic RAG Application (PowerShell)

Write-Host "🚀 Setting up Agentic RAG Application..." -ForegroundColor Cyan

# Check if Python is installed
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python not found. Please install Python 3.8+ from https://www.python.org/" -ForegroundColor Red
    exit 1
}

# Create virtual environment
Write-Host "`n📦 Creating virtual environment..." -ForegroundColor Cyan
if (Test-Path ".venv") {
    Write-Host "⚠️  Virtual environment already exists. Skipping..." -ForegroundColor Yellow
} else {
    python -m venv .venv
    Write-Host "✅ Virtual environment created" -ForegroundColor Green
}

# Activate virtual environment and install dependencies
Write-Host "`n📥 Installing dependencies..." -ForegroundColor Cyan
.\.venv\Scripts\pip.exe install --upgrade pip
.\.venv\Scripts\pip.exe install -r requirements.txt

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

# Check if .env file exists
Write-Host "`n🔑 Checking environment configuration..." -ForegroundColor Cyan
if (Test-Path ".env") {
    Write-Host "✅ .env file found" -ForegroundColor Green
} else {
    Write-Host "⚠️  .env file not found. Copying from .env.example..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "⚠️  Please edit .env file with your Azure OpenAI credentials" -ForegroundColor Yellow
}

Write-Host "`n✅ Setup complete!" -ForegroundColor Green
Write-Host "`nTo run the application:" -ForegroundColor Cyan
Write-Host "  Backend API:  .\run-backend.ps1" -ForegroundColor White
Write-Host "  Frontend UI:  .\run-frontend.ps1" -ForegroundColor White
Write-Host "`nOr run both with:" -ForegroundColor Cyan
Write-Host "  .\run-app.ps1" -ForegroundColor White
