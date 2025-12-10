#!/bin/bash
# Setup script for Agentic RAG Application (Bash)

echo "🚀 Setting up Agentic RAG Application..."

# Check if Python is installed
if command -v python3 &>/dev/null; then
    PYTHON_CMD=python3
elif command -v python &>/dev/null; then
    PYTHON_CMD=python
else
    echo "❌ Python not found. Please install Python 3.8+ from https://www.python.org/"
    exit 1
fi

PYTHON_VERSION=$($PYTHON_CMD --version)
echo "✅ Python found: $PYTHON_VERSION"

# Create virtual environment
echo ""
echo "📦 Creating virtual environment..."
if [ -d ".venv" ]; then
    echo "⚠️  Virtual environment already exists. Skipping..."
else
    $PYTHON_CMD -m venv .venv
    echo "✅ Virtual environment created"
fi

# Activate virtual environment and install dependencies
echo ""
echo "📥 Installing dependencies..."
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Check if .env file exists
echo ""
echo "🔑 Checking environment configuration..."
if [ -f ".env" ]; then
    echo "✅ .env file found"
else
    echo "⚠️  .env file not found. Copying from .env.example..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your Azure OpenAI credentials"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the application:"
echo "  Backend API:  ./run-backend.sh"
echo "  Frontend UI:  ./run-frontend.sh"
echo ""
echo "Or run both with:"
echo "  ./run-app.sh"
