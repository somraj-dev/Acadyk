# Acadyk: CTO & Architecture Blueprint

Welcome to the central technical and product source of truth for **Acadyk**. This workspace serves as a living document to guide the design, implementation, and scaling of Acadyk from MVP to an enterprise-grade professional and academic ecosystem.

---

## 🧭 Official Technology Stack

```
           ┌──────────────────────────────────────────────┐
           │             Flutter Mobile App               │
           │            (Dart / Clean / Riverpod)         │
           └──────────────────────┬───────────────────────┘
                                  │
                                  ▼
                             API Gateway
                                  │
                   ┌──────────────┴──────────────┐
                   │                             │
                   ▼                             ▼
              Go Backend                 Python AI Services
       (REST, Business Logic,      (Independent Microservices,
         Auth, WebSockets)           FastAPI, RAG, NLP)
                   │                             │
                   ├──────────────┬──────────────┤
                   ▼              ▼              ▼
              PostgreSQL        Redis        OpenSearch
           (Core relational  (Cache, Rate (Lexical & Vector Search,
              datastore)       limiter)     Global match index)
                                  │
                                  ▼
                            Cloud Storage
                     (S3-compatible Object Store)
```

---

## 🗺️ Master Roadmap & Phases

Explore the detailed technical specifications and strategic plans across the primary phases of building the Acadyk platform:

1. **[Phase 1: Product Vision](file:///c:/Users/HP/Acadyk/docs/phase_1_product_vision.md)**
   * Core Mission, Vision, and Value Propositions
   * Competitive Analysis (LinkedIn, ResearchGate, Coursera, GitHub)
   * Success Metrics (AARRR Engine)

2. **[Phase 2: Product Strategy](file:///c:/Users/HP/Acadyk/docs/phase_2_product_strategy.md)**
   * MVP Scoping & Core Persona Breakdown
   * Pricing Plans & Monetization Strategy
   * B2B & B2C Subscription Models & Growth Loops

3. **[Phase 3: System Architecture](file:///c:/Users/HP/Acadyk/docs/phase_3_system_architecture.md)**
   * High-Level Go Monolith & Python AI Microservices Diagram
   * Event-Driven Communication Patterns
   * Notification & Messaging Architectural Flows

4. **[Phase 4: Technology Stack](file:///c:/Users/HP/Acadyk/docs/phase_4_technology_stack.md)**
   * Primary Languages & Frameworks (Go, Flutter, Python FastAPI)
   * Datastore Strategies (PostgreSQL, OpenSearch, Redis, S3 Object Storage)
   * Technology Alternatives & Trade-Off Matrix

5. **[Phase 5: Database Planning](file:///c:/Users/HP/Acadyk/docs/phase_5_database_planning.md)**
   * Entity Relationship Diagrams (ERDs via Mermaid)
   * Indexing, Go Schema Tagging & Query Optimizations
   * Multi-Tenancy Strategy (SaaS for Universities/Startups)

6. **[Phase 6: Product Modules](file:///c:/Users/HP/Acadyk/docs/phase_6_product_modules.md)**
   * In-Depth Breakdown of Core Modules (Auth, Feed, Jobs, Communities, etc.)
   * API Specs, Data Entities, Security Considerations, and Future Upgrades

7. **[Phase 7: UI/UX Planning](file:///c:/Users/HP/Acadyk/docs/phase_7_ui_ux_planning.md)**
   * Flutter Design System, Material Design 3 UI styling
   * Typography, Accessibility (WCAG 2.1 AA), Mobile-First Interactions
   * **[Home Feed UX Specification & Design System](file:///c:/Users/HP/Acadyk/docs/phase_7_home_feed_design.md)** (Wireframes, Card components, AI integrations, Spacing rules)

8. **[Phase 8: Development Roadmap & Scaling](file:///c:/Users/HP/Acadyk/docs/phase_8_development_roadmap.md)**
   * Milestone Matrix (Alpha, Beta, Public Launch, Scale)
   * Scaling Strategy: Evolution from 100 to 10 Million Users

9. **[Phase 9: Engineering Standards](file:///c:/Users/HP/Acadyk/docs/phase_9_engineering_standards.md)**
   * Go Backend Standards (Clean Architecture, Dependency Injection)
   * Flutter Clean Feature-First Standards (Riverpod, Freezed, GoRouter)
   * Python AI Standards (FastAPI, Pydantic, Async processing)

10. **[Phase 10: AI Roadmap](file:///c:/Users/HP/Acadyk/docs/phase_10_ai_roadmap.md)**
    * LLM Models & Ingestion Pipelines
    * OpenSearch Vector Search (K-NN indices)
    * Prompting Strategy, Cost & Performance Management

11. **[Phase 11: Security & Compliance](file:///c:/Users/HP/Acadyk/docs/phase_11_security_compliance.md)**
    * Data Encryption, Key Management (AWS KMS)
    * Go middleware rate-limiting, Spam & Fraud Prevention
    * GDPR/CCPA Privacy Safeguards

12. **[Phase 12: DevOps & Deployment](file:///c:/Users/HP/Acadyk/docs/phase_12_devops_deployment.md)**
    * Containerization (Go and Python multi-stage builds) & Kubernetes Configurations
    * CI/CD Pipelines (GitHub Actions)
    * Monitoring (Grafana/Loki) & Disaster Recovery Plans

---

## 🪵 Living Logs & Project Tracking

These documents track our continuous architectural decisions, technical debt, and backlog items:

* **[Decision Log](file:///c:/Users/HP/Acadyk/logs/decision_log.md)**: Structured decisions comparing alternatives, trade-offs, and justifications (ADRs).
* **[Risk Register](file:///c:/Users/HP/Acadyk/logs/risk_register.md)**: Identification of product, operational, and technical risks, with mitigation strategies.
* **[Feature Backlog](file:///c:/Users/HP/Acadyk/logs/feature_backlog.md)**: Prioritized backlog of features mapped by module and target phase.
* **[Technical Debt Log](file:///c:/Users/HP/Acadyk/logs/technical_debt_log.md)**: Known architectural shortcuts, cleanup tasks, and planned refactors.
