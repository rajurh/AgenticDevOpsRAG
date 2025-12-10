# Sample Test Prompts for RAG Application

This document contains sample prompts to test the RAG (Retrieval-Augmented Generation) application.

---

## ✅ In-Scope Prompts (Should Answer Successfully)

### Release and Deployment

1. **"What is our release process?"**
   - Expected: Should describe the feature branch → PR → CI checks → staging → QA → production flow

2. **"Describe the deployment checklist"**
   - Expected: Should list the 6-step deployment checklist including CI checks, migrations, backup, notifications, monitoring, and rollback procedures

3. **"How do we handle hotfixes?"**
   - Expected: Should explain creating a hotfix branch from main and following the hotfix flow

4. **"What versioning scheme do we use?"**
   - Expected: Should mention semantic versioning and tagging release commits

---

### CI/CD and DevOps

5. **"What are our CI/CD pipeline guidelines?"**
   - Expected: Should describe GitHub Actions, linting, testing, security scanning, and environment-specific configurations

6. **"How do we use feature flags?"**
   - Expected: Should mention progressive rollout of risky changes using feature flags

7. **"What should be included in our CI pipeline?"**
   - Expected: Should mention linting, testing, security scanning in pull request checks

8. **"How do we manage deployment approvals?"**
   - Expected: Should mention approval gates for production deployments

---

### Azure and Cloud

9. **"What are Azure deployment best practices?"**
   - Expected: Should describe App Service/Container Apps, auto-scaling, Application Insights, Key Vault, health checks, deployment slots, managed identities

10. **"How should we configure monitoring in Azure?"**
    - Expected: Should mention Application Insights, diagnostic logs, Log Analytics workspace

11. **"What Azure services should we use for web applications?"**
    - Expected: Should recommend Azure App Service or Azure Container Apps

12. **"How do we implement health check endpoints?"**
    - Expected: Should mention /health or /api/health endpoints

---

### Security and Compliance

13. **"What security checks are required before deployment?"**
    - Expected: Should mention security scanning, dependency checks, multi-factor authentication, least privilege, encryption

14. **"How should we store secrets?"**
    - Expected: Should recommend Azure Key Vault for secrets management

15. **"What are our security requirements?"**
    - Expected: Should describe vulnerability scanning, MFA, encryption, security reviews, audit logs, security patches

16. **"How quickly should we apply security patches?"**
    - Expected: Should mention within 48 hours of release

---

### Incident Response

17. **"What should I do when a production issue occurs?"**
    - Expected: Should describe creating incident ticket, assessing severity (P0-P3), paging on-call, using communication channels

18. **"How do we handle P0 incidents?"**
    - Expected: Should mention paging on-call engineer and assembling incident response team

19. **"What happens after an incident?"**
    - Expected: Should describe blameless postmortem within 48 hours and updating runbooks

20. **"How often should we test incident response?"**
    - Expected: Should mention quarterly testing of incident response plan

---

### Operations and SRE

21. **"What monitoring should we implement?"**
    - Expected: Should mention Application Insights, Azure Monitor, Log Analytics

22. **"How do we handle rollbacks?"**
    - Expected: Should mention rolling back if critical errors occur during deployment

23. **"What are network security best practices?"**
    - Expected: Should mention network security groups, private endpoints, rate limiting, DDoS protection

24. **"How long should we monitor after deployment?"**
    - Expected: Should mention monitoring metrics and logs for 30 minutes after deployment

---

## ❌ Out-of-Scope Prompts (Should Politely Decline)

### General Knowledge

25. **"What's the weather today?"**
   - Expected: Should politely decline and redirect to DevOps topics

26. **"Who won the World Cup?"**
   - Expected: Should indicate this is outside the scope and offer to help with DevOps questions

27. **"Tell me a joke"**
   - Expected: Should redirect to asking questions about DevOps, CI/CD, or Azure operations

28. **"What is the capital of France?"**
   - Expected: Should politely indicate this is not related to DevOps/Azure documentation

---

### Personal Questions

29. **"What's your favorite color?"**
   - Expected: Should indicate it can only answer DevOps-related questions

30. **"How old are you?"**
   - Expected: Should redirect to DevOps domain questions

---

### Unrelated Technology

31. **"How do I cook pasta?"**
   - Expected: Should politely decline and suggest asking DevOps/Azure questions

32. **"What's the best programming language?"**
   - Expected: May decline or if it tries to answer, should note it's better at DevOps-specific questions

33. **"How do I fix my WiFi?"**
   - Expected: Should indicate this is outside the scope of DevOps documentation

---

## 🧪 Edge Cases and Validation

### Ambiguous Questions

34. **"How do we deploy?"**
   - Expected: Should ask for clarification or provide general deployment information from the checklist

35. **"What about security?"**
   - Expected: Should provide security-related information from the knowledge base

36. **"Tell me about best practices"**
   - Expected: Should provide overview of best practices from available documents (Azure, CI/CD, security)

---

### Complex Multi-Part Questions

37. **"What is our release process and how do we handle security?"**
   - Expected: Should address both parts, describing release process and security requirements

38. **"How do we deploy to Azure and monitor the application?"**
   - Expected: Should cover both Azure deployment and monitoring with Application Insights

---

### Negative/Missing Information

39. **"What is our refund policy?"**
   - Expected: Should indicate this information is not in the DevOps documentation

40. **"How do we handle customer complaints?"**
   - Expected: Should indicate this is outside the scope unless there's an incident response angle

---

## 📊 Testing Guidelines

### How to Evaluate Responses

1. **Accuracy**: Does the answer match the source documents?
2. **Relevance**: Does it answer the specific question asked?
3. **Citations**: Does it reference which source(s) were used?
4. **Scope Handling**: Does it properly decline out-of-scope questions?
5. **Helpfulness**: Is the answer actionable and clear?

### Expected Response Format

For in-scope questions:
```
[Direct answer to the question]

Sources used:
- [Document title 1] (source: [source name])
- [Document title 2] (source: [source name])
```

For out-of-scope questions:
```
I can only answer questions related to DevOps, deployments, CI/CD pipelines, 
and Azure operations based on our documentation. Please ask questions within this domain.
```

---

## 🎯 Quick Test Suite

### Minimal Test Set (5 questions)

1. "What is our release process?" (should succeed)
2. "What are Azure deployment best practices?" (should succeed)
3. "How do we handle incidents?" (should succeed)
4. "What's the weather today?" (should decline)
5. "Tell me a joke" (should decline)

### Comprehensive Test Set (10 questions)

1. "What is our release process?"
2. "Describe the deployment checklist"
3. "What are our CI/CD pipeline guidelines?"
4. "What are Azure deployment best practices?"
5. "What security checks are required?"
6. "What should I do when a production issue occurs?"
7. "How should we store secrets?"
8. "What's the weather today?" (out of scope)
9. "Who won the World Cup?" (out of scope)
10. "How do I cook pasta?" (out of scope)

---

## 📝 Response Quality Metrics

Track these metrics when testing:

- **Accuracy Rate**: % of correct answers for in-scope questions
- **Scope Compliance**: % of out-of-scope questions properly declined
- **Citation Rate**: % of answers that include source citations
- **Average Response Time**: Time to generate answers
- **Relevance Score**: How well answers match the question (1-5 scale)

---

## 🔧 Using These Prompts

### In Streamlit UI
1. Open the application at http://localhost:8501
2. Copy a prompt from this document
3. Paste into the question field
4. Click "Ask"
5. Evaluate the response

### In API Testing
```powershell
curl -X POST http://127.0.0.1:8001/api/query `
  -H "Content-Type: application/json" `
  -d '{"query":"What is our release process?"}'
```

### In Automated Tests
Create a test script that iterates through prompts and validates responses programmatically.
