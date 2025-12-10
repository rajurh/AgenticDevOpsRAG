#!/usr/bin/env bash
set -euo pipefail

# Setup script for Agentic RAG Application (Bash/Git Bash/CI)
echo "🚀 Setting up Agentic RAG Application..."

# Detect python: try candidates and validate the command actually runs.
PYTHON_CMD=""
PYTHON_VERSION=""

# candidate names; 'py' will be used as 'py -3'
candidates=(python3 python py)
for cand in "${candidates[@]}"; do
    if command -v "$cand" >/dev/null 2>&1; then
        if [ "$cand" = "py" ]; then
            probe_cmd="py -3"
        else
            probe_cmd="$cand"
        fi
        # Try to run --version and inspect output for MS Store/alias messages
        out=$(eval "$probe_cmd --version" 2>&1 || true)
        # If the command succeeded and doesn't contain the MS Store/alias text, accept it
        if [ $? -eq 0 ] && ! echo "$out" | grep -qiE "(was not found|Microsoft Store|App Execution Alias)"; then
            PYTHON_CMD="$probe_cmd"
            PYTHON_VERSION="$out"
            break
        fi
    fi
done

# As a last resort, try common explicit Windows python path(s)
if [ -z "$PYTHON_CMD" ]; then
    if [ -x "/c/Python312/python.exe" ] || [ -x "C:/Python312/python.exe" ]; then
        if [ -x "/c/Python312/python.exe" ]; then
            PYTHON_CMD="/c/Python312/python.exe"
        else
            PYTHON_CMD="C:/Python312/python.exe"
        fi
        PYTHON_VERSION=$(eval "$PYTHON_CMD --version" 2>&1 || true)
    fi
fi

if [ -z "$PYTHON_CMD" ]; then
    echo "❌ Python not found or the detected python command is the MS Store alias."
    echo "Please install Python 3.8+ from https://www.python.org/ and ensure the real python executable is on PATH." 
    echo "On Windows, disable the App Execution Alias for 'python' in Settings → Apps → Advanced app execution aliases if it interferes."
    exit 1
fi

echo "✅ Python found: $PYTHON_VERSION"

echo ""
echo "📦 Creating virtual environment..."
if [ -d ".venv" ]; then
    echo "⚠️  Virtual environment already exists. Skipping creation."
else
    echo "🔧 Creating .venv using: $PYTHON_CMD"
    eval "$PYTHON_CMD -m venv .venv"
    echo "✅ Virtual environment created"
fi

echo ""
echo "📥 Installing dependencies..."

# Prefer using the venv python executable directly (works on Git Bash and PowerShell)
VENV_PY=""
if [ -f ".venv/Scripts/python.exe" ]; then
    VENV_PY=".venv/Scripts/python.exe"
elif [ -f ".venv/bin/python" ]; then
    VENV_PY=".venv/bin/python"
fi

if [ -z "$VENV_PY" ]; then
    echo "❌ Could not locate python executable inside .venv. The venv may not have been created correctly."
    echo "Try recreating the venv with an explicit Python interpreter, for example: 'py -3 -m venv .venv' or 'C:/Python312/python.exe -m venv .venv'"
    exit 1
fi

echo "🔁 Using venv python: $VENV_PY"
"$VENV_PY" -m pip install --upgrade pip || true
"$VENV_PY" -m pip install -r requirements.txt || {
    echo "❌ Failed to install dependencies using venv python. See pip output above for resolution errors."
    exit 1
}

echo "✅ Dependencies installed successfully"

echo ""
echo "🔑 Checking environment configuration..."
if [ -f ".env" ]; then
    echo "✅ .env file found"
else
    if [ -f ".env.example" ]; then
        echo "⚠️  .env file not found. Copying from .env.example..."
        cp .env.example .env
        echo "⚠️  Please edit .env file with your Azure OpenAI credentials"
    else
        echo "⚠️  .env file and .env.example not found — set required environment variables manually."
    fi
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the application:" 
echo "  Backend API:  ./run-backend.sh  (or: .venv/Scripts/python.exe -m uvicorn app:app --host 127.0.0.1 --port 8001)"
echo "  Frontend UI:  ./run-frontend.sh  (or: .venv/Scripts/python.exe -m streamlit run streamlit_app.py)"
echo ""
echo "Or run both with:" 
echo "  ./run-app.sh"
