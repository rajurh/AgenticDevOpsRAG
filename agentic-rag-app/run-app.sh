#!/bin/bash
# Run both backend and frontend

echo "🚀 Starting Agentic RAG Application..."

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "❌ Virtual environment not found. Please run setup.sh first"
    exit 1
fi

source .venv/bin/activate

echo ""
echo "📌 This will start two services:"
echo "   1. Backend API on http://127.0.0.1:8001"
echo "   2. Frontend UI on http://localhost:8501"
echo ""
echo "⚠️  Press Ctrl+C to stop both services"
echo ""

# Start backend in background
uvicorn app:app --host 127.0.0.1 --port 8001 &
BACKEND_PID=$!
echo "✅ Backend API started (PID: $BACKEND_PID)"

sleep 3

# Start frontend in foreground
export RAG_BASE="http://127.0.0.1:8001"
trap "echo ''; echo '🛑 Stopping backend API...'; kill $BACKEND_PID 2>/dev/null; echo '✅ Application stopped'; exit" INT TERM

streamlit run streamlit_app.py
