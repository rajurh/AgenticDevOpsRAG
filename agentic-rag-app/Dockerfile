# Single-container image that runs both FastAPI backend and Streamlit UI behind nginx
# - FastAPI (uvicorn) on internal port 8001
# - Streamlit on internal port 8501
# - nginx listens on 80 and reverse-proxies /api to FastAPI and / to Streamlit

FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
WORKDIR /app

# Install system deps (nginx) and cleanup
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx curl ca-certificates build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY . /app

# Put nginx site config in place
RUN mkdir -p /etc/nginx/sites-enabled
COPY docker/nginx.conf /etc/nginx/sites-enabled/default

# Ensure start script is executable
RUN chmod +x /app/start.sh

# Expose the external port
EXPOSE 80

# Start both services via start.sh (starts uvicorn, streamlit, then nginx)
CMD ["/app/start.sh"]
