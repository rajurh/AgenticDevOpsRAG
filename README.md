# AgenticDevOpsRAG

A Retrieval-Augmented Generation (RAG) application for DevOps knowledge management, built with Azure OpenAI, FastAPI, and Streamlit.

## Overview

AgenticDevOpsRAG is an intelligent assistant that helps teams answer questions about DevOps practices, deployment processes, CI/CD pipelines, security requirements, and Azure operations. The application uses RAG technology to retrieve relevant information from a knowledge base and generate contextual responses using Azure OpenAI.

### Key Features

- **Intelligent Query Processing**: Uses Azure OpenAI embeddings to find relevant documentation
- **Conversational Interface**: Streamlit-based UI for easy interaction
- **RESTful API**: FastAPI backend for programmatic access
- **Scope-Aware Responses**: Only answers DevOps-related questions within its knowledge domain
- **Containerized Deployment**: Single-container Docker image with nginx reverse proxy
- **Azure-Ready**: Designed for Azure App Service and Container Apps deployment
- **Health Monitoring**: Built-in health check endpoints for observability

## Architecture

The application consists of three main components running in a single container:

```
┌─────────────────────────────────────────┐
│         Docker Container (Port 80)       │
├─────────────────────────────────────────┤
│                                          │
│  ┌────────────────────────────────┐    │
│  │         nginx (Port 80)         │    │
│  │  - Routes /api/* → FastAPI      │    │
│  │  - Routes /* → Streamlit        │    │
│  └────────────────────────────────┘    │
│           ↓                ↓             │
│  ┌─────────────┐   ┌──────────────┐   │
│  │   FastAPI   │   │  Streamlit   │   │
│  │ (Port 8001) │   │ (Port 8501)  │   │
│  └─────────────┘   └──────────────┘   │
│           ↓                              │
│  ┌────────────────────────────────┐    │
│  │       RAG Engine               │    │
│  │  - Vector Store (In-Memory)    │    │
│  │  - Azure OpenAI Client         │    │
│  └────────────────────────────────┘    │
│                                          │
└─────────────────────────────────────────┘
```

### Components

- **FastAPI Backend** (`app.py`): REST API that handles query requests and health checks
- **Streamlit UI** (`streamlit_app.py`): Web interface for interactive queries
- **RAG Core** (`rag_core.py`): Implements retrieval-augmented generation logic
- **Vector Store** (`vector_store.py`): In-memory vector storage for document embeddings
- **nginx**: Reverse proxy that routes traffic to the appropriate service

### Data Flow

1. User submits a query via UI or API
2. Query is embedded using Azure OpenAI embeddings
3. Vector store retrieves top-K most relevant documents
4. Retrieved context + query sent to Azure OpenAI for response generation
5. Response returned with source citations

## Prerequisites

- **Python 3.11+** (for local development)
- **Docker** (for containerized deployment)
- **Azure OpenAI Service** with:
  - Embeddings deployment (e.g., text-embedding-ada-002)
  - Chat completions deployment (e.g., gpt-4 or gpt-35-turbo)
- **Azure CLI** (for Azure deployment)

## Running Locally

### Option 1: Docker (Recommended)

1. **Build the Docker image**:
   ```bash
   cd agentic-rag-app
   docker build -t agentic-rag-app:local .
   ```

2. **Run the container**:
   ```bash
   docker run --rm -p 8080:80 \
     -e AZURE_OPENAI_EMBEDDING_URL="<your_embedding_url>" \
     -e AZURE_OPENAI_CHAT_URL="<your_chat_url>" \
     -e AZURE_OPENAI_KEY="<your_api_key>" \
     agentic-rag-app:local
   ```

3. **Access the application**:
   - Web UI: http://localhost:8080
   - API: http://localhost:8080/api/query
   - Health Check: http://localhost:8080/api/health

### Option 2: Local Development

1. **Navigate to the application directory**:
   ```bash
   cd agentic-rag-app
   ```

2. **Create and configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your Azure OpenAI credentials
   ```

3. **Install Python dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Start the FastAPI backend**:
   ```bash
   # Terminal 1
   uvicorn app:app --host 0.0.0.0 --port 8001
   ```

5. **Start the Streamlit UI**:
   ```bash
   # Terminal 2
   streamlit run streamlit_app.py --server.port 8501
   ```

6. **Access the application**:
   - Web UI: http://localhost:8501
   - API: http://localhost:8001/api/query
   - Health Check: http://localhost:8001/health

## Configuration

### Environment Variables

Configure the application using these environment variables:

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `AZURE_OPENAI_EMBEDDING_URL` | Full URL to Azure OpenAI embeddings endpoint | Yes | - |
| `AZURE_OPENAI_CHAT_URL` | Full URL to Azure OpenAI chat completions endpoint | Yes | - |
| `AZURE_OPENAI_KEY` | API key for Azure OpenAI | Yes | - |
| `TOP_K` | Number of documents to retrieve for context | No | 3 |
| `RAG_BASE` | Backend API URL (for Streamlit UI) | No | http://127.0.0.1:8001 |

### Azure OpenAI Endpoint Format

Your endpoint URLs should follow this format:

```
# Embeddings
https://<instance>.openai.azure.com/openai/deployments/<deployment>/embeddings?api-version=2023-05-15

# Chat Completions
https://<instance>.openai.azure.com/openai/deployments/<deployment>/chat/completions?api-version=2025-01-01-preview
```

## Deployment to Azure

### Azure App Service for Containers

1. **Create resource group and ACR**:
   ```bash
   RESOURCE_GROUP="rg-agentic-rag-app"
   LOCATION="eastus"
   ACR_NAME="<your-acr-name>"
   
   az group create -n $RESOURCE_GROUP -l $LOCATION
   az acr create -g $RESOURCE_GROUP -n $ACR_NAME --sku Basic
   ```

2. **Build and push image to ACR**:
   ```bash
   cd agentic-rag-app
   az acr build -r $ACR_NAME -t agentic-rag-app:latest .
   ```

3. **Create App Service Plan and Web App**:
   ```bash
   PLAN="asp-agentic-rag"
   WEBAPP="agentic-rag-app"
   
   az appservice plan create -g $RESOURCE_GROUP -n $PLAN --is-linux --sku B1
   az webapp create -g $RESOURCE_GROUP -p $PLAN -n $WEBAPP \
     --deployment-container-image-name "$ACR_NAME.azurecr.io/agentic-rag-app:latest"
   ```

4. **Configure application settings**:
   ```bash
   az webapp config appsettings set -g $RESOURCE_GROUP -n $WEBAPP --settings \
     AZURE_OPENAI_EMBEDDING_URL="<url>" \
     AZURE_OPENAI_CHAT_URL="<url>" \
     AZURE_OPENAI_KEY="<key>" \
     TOP_K=3
   ```

5. **Browse to your App Service URL**

> **Security Note**: For production, use Azure Key Vault references instead of storing secrets directly in App Settings. Consider using managed identities for authentication.

For detailed deployment instructions, see [SINGLE_CONTAINER.md](agentic-rag-app/SINGLE_CONTAINER.md).

## API Usage

### Query Endpoint

**POST** `/api/query`

Request:
```json
{
  "query": "What is our release process?"
}
```

Response:
```json
{
  "answer": "The release process follows: feature branch -> PR -> CI checks -> staging deployment -> QA signoff -> production deploy...",
  "sources": [
    {
      "title": "Release Process Overview",
      "source": "internal-handbook",
      "text": "Release process: feature branch -> PR..."
    }
  ],
  "query": "What is our release process?"
}
```

### Health Check Endpoint

**GET** `/health`

Response:
```json
{
  "status": "ok",
  "azure_openai": {
    "configured": true,
    "connection": "healthy"
  },
  "vector_store": {
    "document_count": 6
  }
}
```

### Example: Using curl

```bash
curl -X POST http://localhost:8080/api/query \
  -H "Content-Type: application/json" \
  -d '{"query":"What are our CI/CD pipeline guidelines?"}'
```

### Example: Using PowerShell

```powershell
Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/query" `
  -ContentType "application/json" `
  -Body '{"query":"What are our CI/CD pipeline guidelines?"}'
```

## Knowledge Base

The application's knowledge base is stored in JSON files in the `agentic-rag-app/data/` directory. Each document follows this format:

```json
{
  "meta": {
    "title": "Document Title",
    "source": "source-identifier"
  },
  "text": "Document content..."
}
```

The knowledge base currently includes documents about:
- Release processes
- Deployment checklists
- CI/CD pipeline guidelines
- Azure deployment best practices
- Security requirements
- Incident response procedures

To add new documents, create a new JSON file in the `data/` directory following the format above.

## Testing

Sample test prompts are provided in [TEST_PROMPTS.md](agentic-rag-app/TEST_PROMPTS.md). These include:

- **In-scope questions**: DevOps, CI/CD, security, Azure operations
- **Out-of-scope questions**: General knowledge, personal questions (should be declined)
- **Edge cases**: Ambiguous questions, multi-part queries

Example test queries:
- ✅ "What is our release process?"
- ✅ "How do we handle production incidents?"
- ✅ "What are Azure deployment best practices?"
- ❌ "What's the weather today?" (should decline)

## Project Structure

```
AgenticDevOpsRAG/
├── agentic-rag-app/
│   ├── data/                  # Knowledge base documents (JSON)
│   ├── docker/                # Docker configuration files
│   │   └── nginx.conf         # nginx reverse proxy config
│   ├── infra/                 # Infrastructure as Code
│   ├── .streamlit/            # Streamlit configuration
│   ├── app.py                 # FastAPI backend
│   ├── streamlit_app.py       # Streamlit UI
│   ├── rag_core.py            # RAG implementation
│   ├── vector_store.py        # Vector storage
│   ├── errors.py              # Custom error classes
│   ├── logging_config.py      # Logging configuration
│   ├── requirements.txt       # Python dependencies
│   ├── Dockerfile             # Container image definition
│   ├── start.sh               # Container startup script
│   ├── .env.example           # Environment template
│   ├── SINGLE_CONTAINER.md    # Deployment documentation
│   └── TEST_PROMPTS.md        # Testing guide
└── README.md                  # This file
```

## Troubleshooting

### Common Issues

**Issue**: "Azure OpenAI configuration missing" error

**Solution**: Ensure all required environment variables are set:
- `AZURE_OPENAI_EMBEDDING_URL`
- `AZURE_OPENAI_CHAT_URL`
- `AZURE_OPENAI_KEY`

---

**Issue**: UI cannot reach the API

**Solution**: 
- For Docker: Ensure nginx is running and proxying correctly
- For local dev: Set `RAG_BASE` environment variable to point to FastAPI server
- Check logs for connection errors

---

**Issue**: Container fails to start

**Solution**:
- Check container logs: `docker logs <container-id>`
- Verify all environment variables are provided
- Ensure ports 8001 and 8501 are not already in use inside the container

---

**Issue**: Empty or incorrect responses

**Solution**:
- Verify Azure OpenAI endpoints are accessible
- Check API key is valid
- Use the health check endpoint to verify configuration
- Ensure knowledge base documents exist in `data/` directory

---

**Issue**: Health check shows "unhealthy" connection

**Solution**:
- Verify Azure OpenAI endpoints are correct and include API version
- Check network connectivity to Azure OpenAI
- Verify API key has necessary permissions
- Check Azure OpenAI service quotas and limits

## Development

### Adding New Documents

1. Create a JSON file in `agentic-rag-app/data/`
2. Follow the format: `{"meta": {"title": "...", "source": "..."}, "text": "..."}`
3. Restart the application to load new documents

### Modifying the RAG Logic

Key files:
- `rag_core.py`: RAG implementation and Azure OpenAI client
- `vector_store.py`: Vector storage and similarity search
- `app.py`: API endpoints and request handling

### Local Development Tips

- Use `.env` file for environment variables (copy from `.env.example`)
- Check health endpoint regularly during development
- Use the Streamlit diagnostics panel to verify backend connectivity
- Monitor logs for error messages and performance issues

## Security Considerations

- **Never commit secrets**: Use environment variables or Azure Key Vault
- **Use managed identities**: For Azure deployments, use managed identities instead of API keys
- **Keep dependencies updated**: Regularly update Python packages
- **Enable HTTPS**: Use HTTPS in production deployments
- **Implement rate limiting**: Add rate limiting for production APIs
- **Monitor access**: Use Application Insights to track usage and errors

## License

[Add your license information here]

## Contributing

[Add contribution guidelines here]

## Support

For issues and questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review [TEST_PROMPTS.md](agentic-rag-app/TEST_PROMPTS.md) for usage examples
- See [SINGLE_CONTAINER.md](agentic-rag-app/SINGLE_CONTAINER.md) for deployment details
