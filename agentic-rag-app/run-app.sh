#!/usr/bin/env bash
set -euo pipefail

# Run both backend and frontend in Git Bash (Windows-friendly)
echo "🚀 Starting Agentic RAG Application..."

# Ensure we're in repo root (script assumes it's executed from project root)

# Check for virtual environment
if [ ! -d ".venv" ]; then
    echo "❌ Virtual environment not found. Please run ./setup.sh first to create and install dependencies."
    exit 1
fi

# Locate the activate script for bash (supports Linux/macOS and Git Bash on Windows)
ACTIVATE=""
if [ -f ".venv/bin/activate" ]; then
    ACTIVATE=".venv/bin/activate"
elif [ -f ".venv/Scripts/activate" ]; then
    ACTIVATE=".venv/Scripts/activate"
fi

if [ -z "$ACTIVATE" ]; then
    echo "❌ Could not find a shell activate script in .venv. Ensure you created the venv with 'python -m venv .venv' and installed requirements." 
    exit 1
fi

# shellcheck disable=SC1091
source "$ACTIVATE"

echo ""
echo "📌 This will start two services:" 
echo "   1. Backend API on http://127.0.0.1:8001"
echo "   2. Frontend UI on http://localhost:8501"
echo ""
echo "⚠️  Press Ctrl+C to stop both services"
echo ""

find_pid_by_port() {
    local PORT=$1
    # Use netstat which is available on Windows + Git Bash; parse the PID from last column
    PID=$(netstat -ano 2>/dev/null | grep -E ":[[:digit:]]+:${PORT}|:${PORT}[[:space:]]" || true)
    if [ -n "$PID" ]; then
        # get last column (PID). netstat output varies; use awk to be robust
        echo "$PID" | awk '{print $NF}' | head -n1
    else
        echo ""
    fi
}

kill_if_port_in_use() {
    local PORT=$1
    local P=$(find_pid_by_port "$PORT")
    if [ -n "$P" ]; then
        if [ "${FORCE_FREE_PORTS:-}" = "1" ]; then
            echo "⚠️  Killing process ${P} using port ${PORT}"
            kill $P 2>/dev/null || taskkill /PID $P /F 2>/dev/null || true
        else
            echo "❗ Port ${PORT} appears in use by PID ${P}."
            read -r -p "Do you want to kill it? [y/N]: " ans || true
            if [[ "$ans" =~ ^[Yy]$ ]]; then
                kill $P 2>/dev/null || taskkill /PID $P /F 2>/dev/null || true
            else
                echo "Please free port ${PORT} and retry. Exiting."; exit 1
            fi
        fi
    fi
}

# Check and optionally free ports commonly used by the app
kill_if_port_in_use 8001
kill_if_port_in_use 8501

# Ensure uvicorn and streamlit are available in PATH (should be after sourcing .venv)
if ! command -v uvicorn >/dev/null 2>&1; then
    echo "❌ 'uvicorn' not found in PATH. Activate .venv or install requirements: pip install -r requirements.txt"
    exit 1
fi
if ! command -v streamlit >/dev/null 2>&1; then
    echo "❌ 'streamlit' not found in PATH. Activate .venv or install requirements: pip install -r requirements.txt"
    exit 1
fi

# Start backend in background
echo "🔧 Starting backend: uvicorn app:app --host 127.0.0.1 --port 8001"
uvicorn app:app --host 127.0.0.1 --port 8001 &
BACKEND_PID=$!
echo "✅ Backend API started (PID: $BACKEND_PID)"

# Wait for backend to be ready (try hitting openapi.json or root)
echo "⏱ Waiting for backend to become available on http://127.0.0.1:8001 ..."
READY=0
for i in $(seq 1 20); do
    if command -v curl >/dev/null 2>&1; then
        if curl -sS --head http://127.0.0.1:8001/ >/dev/null 2>&1 || curl -sS --head http://127.0.0.1:8001/docs >/dev/null 2>&1; then
            READY=1; break
        fi
    else
        # fallback: check if port is listening
        if find_pid_by_port 8001 >/dev/null 2>&1; then
            READY=1; break
        fi
    fi
    sleep 1
done

if [ "$READY" -ne 1 ]; then
    echo "⚠️  Backend did not respond within timeout. Check logs. Proceeding to start frontend anyway."
fi

export RAG_BASE="http://127.0.0.1:8001"

trap 'echo "\n🛑 Stopping backend API..."; kill $BACKEND_PID 2>/dev/null || true; echo "✅ Application stopped"; exit' INT TERM

echo "🔧 Starting Streamlit UI"
streamlit run streamlit_app.py
