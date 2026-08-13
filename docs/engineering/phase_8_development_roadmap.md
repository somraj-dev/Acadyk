# Phase 8: Development Roadmap & Scaling Strategy

This roadmap outlines the milestones from initial MVP build to public scaling, alongside the step-by-step infrastructure strategy for growing the user base from 100 to 10,000,000 users.

---

## 🗺️ Milestones Timeline

```
┌───────────────────────────┐    ┌───────────────────────────┐    ┌───────────────────────────┐
│  M1: Core Identity (M1-2) │───>│  M2: Alpha Network (M3-4) │───>│  M3: Monetization (M5-6)  │
│  - Go Auth, Profiles, RAG  │    │  - Go WebSockets, Py AI   │    │  - OpenSearch KNN, Stripe │
└───────────────────────────┘    └───────────────────────────┘    └───────────────────────────┘
```

### Milestone 1: Core Identity & AI Foundation (Months 1–2)
* **Objective**: Build the Go auth, profile engines, and link them to the Python FastAPI Resume Analyzer.
* **Tasks**:
  * Set up PostgreSQL schemas and Go GORM models.
  * Integrate GitHub and Google OAuth in Go.
  * Configure the Python FastAPI service to parse PDF resumes and return JSON schemas.
* **Testing Requirements**: unit test coverage >80% on Go handlers, mock Python endpoints.
* **DoD**: Profile page loads under 150ms on mobile clients.

### Milestone 2: Alpha Social Network (Months 3–4)
* **Objective**: Launch real-time feeds, Direct Messaging via Go WebSockets, and OpenSearch integration.
* **Tasks**:
  * Set up `gorilla/websocket` client-connection hub in Go.
  * Deploy OpenSearch for indexing user profile skills and public posts.
  * Launch group workspace channels on the mobile app.
* **Testing Requirements**: Load test Go WebSocket connections (10,000 concurrent sockets).
* **DoD**: Direct messages are delivered under 50ms.

### Milestone 3: Monetization & Public Launch (Months 5–6)
* **Objective**: Integrate Stripe payment flows, publish OpenSearch k-NN semantic candidate search, and LMS.
* **Tasks**:
  * Implement Stripe billing in the Go backend.
  * Establish k-NN indexes in OpenSearch to filter candidates semantically based on Python AI embeddings.
  * Deliver Flutter screens for online courses.
* **Testing Requirements**: Penetration testing on Go checkout routes, load testing on OpenSearch queries.
* **DoD**: Recruiter candidates search returns query answers under 250ms.

---

## 📈 Scaling Strategy (100 to 10M Users)

We leverage the concurrency of Go and the distributed architecture of OpenSearch to scale our system horizontally.

```
       100 Users          10,000 Users         100,000 Users         10,000,000 Users
    ┌─────────────┐     ┌─────────────┐       ┌─────────────┐       ┌─────────────────┐
    │ Single App  │────>│ RDS replica │──────>│ Kubernetes  │──────>│ Microservices   │
    │ VM (Render) │     │ + Redis Cache│      │ + Kafka Bus │       │ + DB Sharding   │
    └─────────────┘     └─────────────┘       └─────────────┘       └─────────────────┘
```

### 1. Scaling to 100 Users
* **Architecture**: Single Docker container for the Go monolith, one container for Python AI, and a shared PostgreSQL database. OpenSearch is run as a single-node setup.

### 2. Scaling to 1,000 Users
* **Architecture**: Add **Redis** cache for reading hotspots (e.g., active recruiter searches, trending posts).
* **Action**: Configure database connection pooling in Go (`sql.DB.SetMaxOpenConns`).

### 3. Scaling to 10,000 Users
* **Architecture**: Spin up one **RDS Read Replica** to offload read traffic. Migrate OpenSearch from a single node to a **3-node cluster** to handle higher indexing and query volumes.
* **Action**: Run the Python AI microservice behind a load balancer with multiple stateless container replicas.

### 4. Scaling to 100,000 Users
* **Architecture**: Deploy to **Kubernetes (AWS EKS)**.
* **Action**: Implement Change Data Capture (CDC) pipelines using Kafka to stream PostgreSQL updates directly to OpenSearch, keeping search indexes synced in real time.

### 5. Scaling to 1,000,000 Users
* **Architecture**: **Extract Go Monolith into Microservices**.
* **Action**: Split critical Go modules (Messaging, Feed, Notifications) into independent services. Apply **database sharding** on Postgres tables.

### 6. Scaling to 10,000,000 Users
* **Architecture**: Multi-region active-active Kubernetes clusters, geographically distributed OpenSearch clusters, and global edge CDNs.
