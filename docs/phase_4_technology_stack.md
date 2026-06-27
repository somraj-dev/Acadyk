# Phase 4: Technology Stack & Decision Matrix

This document lists the official technology stack recommendations for the Acadyk platform, detailing the rationale, alternatives, and trade-offs for each architectural tier.

---

## 📱 Mobile UI Tier: Flutter (Dart)
* **Role**: Single codebase for cross-platform Android and iOS client apps.
* **Alternative 1: React Native**
  * *Trade-off*: Shared JavaScript context with web development, but slower rendering canvas, and heavily dependent on native bridges that can stutter during feed scrolling or complex animations.
* **Alternative 2: Native Swift & Kotlin**
  * *Trade-off*: Absolute best performance, but doubles UI engineering costs and splits the development team into two isolated stacks.
* **CTO Recommendation (Flutter)**: Offers high performance (compiling to native ARM instructions) and visual consistency across iOS and Android using Material Design 3 templates. Enforces structured development via Riverpod and Clean Architecture patterns.

---

## ⚙️ Backend Services Tier: Go (Golang)
* **Role**: Handles core routing, business logic, authorization, payments, feeds, and persistent WebSocket connections.
* **Alternative 1: Node.js (NestJS / TypeScript)**
  * *Trade-off*: Shared language stack with the web frontend, but higher memory consumption and lower performance on heavy CPU calculations compared to Go.
* **Alternative 2: Python (Django/FastAPI for entire backend)**
  * *Trade-off*: Unifies coding language with AI services, but slower execution speeds, higher runtime footprint, and lacks Go’s simple static compilation structures.
* **CTO Recommendation (Go)**: Go's compile times are extremely fast, memory usage is tiny (typically ~20MB idle), and its built-in goroutine scheduler handles concurrent connections efficiently. This makes Go the ideal choice for high-volume network APIs.

---

## 🤖 AI Services Tier: Python (FastAPI / Pydantic)
* **Role**: Standalone AI microservice managing LLM prompts, RAG embedding creation, NLP parsing, and candidate matching scores.
* **Alternative 1: Go (Writing AI algorithms directly in Go)**
  * *Trade-off*: Removes inter-service network calls, but the Go ecosystem lacks mature machine learning, preprocessing, and LLM helper libraries (like PyTorch or LangChain).
* **Alternative 2: Node.js (Langchain.js)**
  * *Trade-off*: Simpler to integrate with a JS frontend, but lacks data-science libraries (pandas, numpy, scikit-learn) which are necessary for candidate profiling and citation graphing.
* **CTO Recommendation (Python + FastAPI)**: FastAPI provides high-speed asynchronous processing, native Pydantic validation schemas, and direct compatibility with standard ML APIs.

---

## 🗄️ Database & Storage Tiers

### 1. Primary Database: PostgreSQL
* **Role**: Relational datastore containing users, profiles, institutional records, and course progression tables.
* **CTO Recommendation (PostgreSQL)**: The industry gold standard for ACID compliance, support for multi-tenancy models, and JSONB structures.

### 2. Search & Vector Engine: OpenSearch
* **Role**: Handles global autocomplete searches, lexical candidate screening, and semantic vector similarity searches (k-NN).
* **Alternative 1: Elasticsearch + Qdrant (Split Search)**
  * *Trade-off*: Highly performant, but doubles DevOps deployment effort, requires managing two separate query systems, and increases cloud hosting bills.
* **Alternative 2: PostgreSQL (Full Text Search + PGVector)**
  * *Trade-off*: Keeps database operations simple, but complex candidate semantic searches will block transaction processing and exhaust database CPU cores.
* **CTO Recommendation (OpenSearch)**: Unifies full-text matching and semantic vector calculations into a single, high-performance distributed search engine.

### 3. Cache: Redis
* **Role**: Rate limiting, session caches, and queue buffers.

### 4. Cloud Storage: S3-Compatible Object Store
* **Role**: Hosting raw resumes, certification PDFs, preprints, and media assets. Media files are stored in S3 and reference URLs are saved in PostgreSQL to prevent database bloat.
