# GitHub Copilot Prompts for Lab Participants

This document contains suggested prompts that participants can use with GitHub Copilot to extend the RAG application with additional functionality.

## 🎯 Purpose

These prompts are designed for hands-on lab exercises where participants will use GitHub Copilot to enhance the application with production-ready features.

---

## 📝 Suggested Prompts for Copilot
### 0. Implement Global Error Handling & LLM Rate-Limit Messaging

**Prompt:**
```
Add a robust, centralized error-handling strategy for the application:
- Create a reusable error handler that catches exceptions from the backend and returns structured JSON with an `error_code`, `message`, and optional `details` fields.
- Update the Streamlit UI to detect when a backend response contains a structured error and display a friendly message to the user.
- Specifically detect LLM rate-limit / quota errors (e.g., status codes or error messages indicating token limit exceeded, rate limit, or quota) and present a clear, actionable message to users like: "Requests are being rate-limited by the language model service — please wait and try again, or contact admin to increase quota." Include the original error details in an expandable section for debugging.
- Ensure non-sensitive tracebacks are returned only when a debug flag (e.g., `DEBUG_DEV`) is enabled; otherwise return a generic user-facing message and log the full traceback server-side.
``` 

**Expected Outcome:**
Participants will implement a central error-handling layer in `app.py` (or middleware) that returns consistent JSON errors, update `streamlit_app.py` to render those errors nicely, and add special-case handling for LLM rate-limit/quota errors so users see actionable guidance instead of a generic 500.

### 1. Add Health Check Endpoint

**Prompt:**
```
Add a health check endpoint at /health in app.py that returns the status of the application and checks if the Azure OpenAI connection is working. Return JSON with status, timestamp, and service_health fields.
```

**Expected Outcome:** Participants will add a `/health` endpoint that can be used for monitoring and load balancer health checks.

---

### 2. Implement Error Handling for Missing Environment Variables

**Prompt:**
```
Improve error handling in app.py to check if required environment variables (AZURE_OPENAI_EMBEDDING_URL, AZURE_OPENAI_CHAT_URL, AZURE_OPENAI_KEY) are set at startup. If missing, return a clear error message to the user with instructions on what to configure.
```

**Expected Outcome:** Better error messages when configuration is missing, improving developer experience.

---

### 3. Add Request Logging and Metrics

**Prompt:**
```
Add logging to the /api/query endpoint in app.py to track query requests, response times, and any errors. Use Python's logging module and include timestamp, query text (truncated), and response time.
```

**Expected Outcome:** Observability improvements to track application usage and performance.

---

### 4. Implement Rate Limiting

**Prompt:**
```
Add simple rate limiting to the /api/query endpoint to prevent abuse. Limit requests to 10 per minute per IP address. Return a 429 status code when the limit is exceeded.
```

**Expected Outcome:** Protection against API abuse and cost control for Azure OpenAI calls.

---

### 5. Add Input Validation

**Prompt:**
```
Add validation to the QueryRequest model in app.py to ensure the query is not empty and does not exceed 500 characters. Return appropriate error messages for invalid inputs.
```

**Expected Outcome:** Better input validation and user-friendly error messages.

---

### 6. Implement Response Caching

**Prompt:**
```
Add a simple in-memory cache for query responses in app.py. Cache responses for identical queries for 5 minutes to reduce Azure OpenAI API calls and improve response time.
```

**Expected Outcome:** Performance optimization and cost reduction through caching.

---

### 7. Add CORS Support

**Prompt:**
```
Add CORS middleware to app.py to allow the API to be called from web browsers in development mode. Configure it to allow all origins in development.
```

**Expected Outcome:** Enable frontend development from different ports/domains.

---

### 8. Improve Error Messages in Streamlit UI

**Prompt:**
```
Enhance error handling in streamlit_app.py to display user-friendly error messages when the backend is unreachable, returns an error, or times out. Include troubleshooting tips.
```

**Expected Outcome:** Better user experience with clear error messages and guidance.

---

### 9. Add Document Statistics Endpoint

**Prompt:**
```
Create a new endpoint /api/stats in app.py that returns statistics about the knowledge base: number of documents, total text length, and list of document titles with sources.
```

**Expected Outcome:** Visibility into the knowledge base contents for administrators.

---

### 10. Implement Retry Logic for Azure OpenAI Calls

**Prompt:**
```
Add retry logic with exponential backoff to the Azure OpenAI API calls in rag_core.py to handle transient failures and rate limiting from the Azure OpenAI service.
```

**Expected Outcome:** Improved reliability when dealing with API rate limits or temporary service issues.

---

### 11. Add Query History Tracking

**Prompt:**
```
Add functionality to track the last 10 queries in memory in app.py. Create a new endpoint /api/history that returns recent queries with timestamps. Do not store sensitive information.
```

**Expected Outcome:** Simple analytics and debugging capability.

---

### 12. Enhance the System Prompt

**Prompt:**
```
Improve the system prompt in rag_core.py to provide more detailed instructions to the LLM about how to format responses, handle ambiguous questions, and cite sources properly.
```

**Expected Outcome:** Better quality responses from the RAG system.

---

### 13. Add Configuration Validation on Startup

**Prompt:**
```
Add a startup check in app.py that validates the .env configuration by attempting a test embedding and chat completion call. Log the results and warn if the configuration seems incorrect.
```

**Expected Outcome:** Early detection of configuration problems.

---

### 14. Implement Graceful Shutdown

**Prompt:**
```
Improve the shutdown event handler in app.py to gracefully close all connections, save any in-memory data if needed, and log shutdown information.
```

**Expected Outcome:** Proper resource cleanup on application shutdown.

---

### 15. Add API Documentation with OpenAPI

**Prompt:**
```
Enhance the FastAPI app in app.py with detailed OpenAPI documentation including descriptions, examples, and response models for all endpoints. Make the documentation accessible at /docs.
```

**Expected Outcome:** Auto-generated API documentation for developers.

---

## 🧪 Testing Prompts

### Test the Health Check Endpoint

**Prompt:**
```
Create a Python script test_health.py that tests the /health endpoint to ensure it returns 200 status and includes the expected JSON fields.
```

---

### Test Error Handling

**Prompt:**
```
Write a test in tests/test_query.py that verifies the API returns appropriate error messages when invalid queries are submitted (empty string, too long, etc.).
```

---

## 💡 Advanced Prompts

### Add Semantic Search with Reranking

**Prompt:**
```
Enhance the vector search in vector_store.py to implement a two-stage retrieval: first retrieve top 10 candidates, then rerank using a cross-encoder model to get the final top 3 most relevant documents.
```

---

### Implement Multi-turn Conversation Support

**Prompt:**
```
Modify the RAG system to support conversation history. Update the QueryRequest model to accept an optional conversation_id and maintain conversation context across multiple queries.
```

---

## 📋 How to Use These Prompts

1. Open the relevant file in VS Code
2. Open GitHub Copilot Chat
3. Copy and paste the prompt
4. Review the suggested code
5. Test the implementation
6. Iterate with follow-up questions if needed

---

## ✅ Success Criteria

After implementing these enhancements, the application should:
- Have robust error handling
- Include health checks for monitoring
- Provide better observability through logging
- Handle edge cases gracefully
- Have proper API documentation
- Be production-ready

---

## 🎓 Learning Objectives

Through these exercises, participants will:
- Learn to use GitHub Copilot effectively for feature development
- Understand production-readiness requirements
- Practice error handling and validation
- Implement monitoring and observability features
- Work with RESTful API best practices
