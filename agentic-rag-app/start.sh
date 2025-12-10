#!/usr/bin/env bash
set -e

# Default ports (can be overridden via env)
API_HOST=127.0.0.1
API_PORT=${API_PORT:-8001}
STREAMLIT_PORT=${STREAMLIT_PORT:-8501}

# Start backend (uvicorn)
echo "Starting FastAPI (uvicorn) on ${API_HOST}:${API_PORT}"
nohup uvicorn app:app --host ${API_HOST} --port ${API_PORT} --log-level info > /var/log/uvicorn.log 2>&1 &
UVICORN_PID=$!

sleep 1

# Start Streamlit (headless)
echo "Starting Streamlit on ${API_HOST}:${STREAMLIT_PORT}"
nohup streamlit run streamlit_app.py --server.headless true --server.port ${STREAMLIT_PORT} --server.address ${API_HOST} > /var/log/streamlit.log 2>&1 &
STREAMLIT_PID=$!

sleep 1

# Start nginx in foreground (so container stays alive)
echo "Starting nginx (foreground)..."
nginx -g 'daemon off;'

# If nginx exits, ensure child processes are terminated
trap "echo 'Stopping children'; kill ${UVICORN_PID} ${STREAMLIT_PID} 2>/dev/null || true" EXIT
