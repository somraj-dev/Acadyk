# Acadyk Project Risk Register

This log identifies, analyzes, and lists mitigations for product, technical, and compliance risks under the official Go/Python/OpenSearch stack.

---

| ID | Risk Description | Category | Impact | Probability | Mitigation Strategy |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RSK-001** | **Exorbitant LLM API Cost Inflation** | Financial / Technical | High | High | • Enforce strict rate-limiting middlewares in Go.<br>• Use **Gemini Context Caching** for static educational docs.<br>• Cache query embeddings in Redis. |
| **RSK-002** | **GDPR Right-to-be-Forgotten Violations** | Legal / Compliance | High | Low | • Cascading deletion triggers in PostgreSQL.<br>• Go worker executes DELETE queries against the OpenSearch k-NN index upon user account termination. |
| **RSK-003** | **Postgres DB Connection Exhaust** | Infrastructure | High | Medium | • Configure Go database pool limits: `db.SetMaxOpenConns(50)` and `db.SetMaxIdleConns(25)`.<br>• Deploy **PgBouncer** connection proxy in front of Amazon RDS. |
| **RSK-004** | **Intellectual Property (IP) Leak during RAG** | Security | Critical | Medium | • Use enterprise APIs with zero data retention clauses (e.g. Google Vertex AI cloud endpoints).<br>• Ensure all student data is anonymized before vector generation. |
