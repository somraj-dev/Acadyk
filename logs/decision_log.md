# Architectural Decision Log (ADR)

This log tracks critical technology decisions, comparisons, and trade-offs made by the technology team.

---

## ADR 001: Core Backend Language Selection

* **Status**: **Approved**
* **Context**: We need to choose the programming language for our primary API monolith to scale to millions of users.
* **Alternatives Evaluated**:
  1. **Node.js (TypeScript/NestJS)**: High development speed, but higher memory usage and lower performance under CPU-intensive loads.
  2. **Python (FastAPI)**: Matches the AI stack, but has slower execution speeds and lacks Go's native concurrent execution performance.
  3. **Go (Golang) (Recommended)**: Compiled language offering native execution speeds, low memory footprint, and goroutine-based concurrency.

### Trade-Off Comparison

| Metric | Node.js | Python | Go |
| :--- | :--- | :--- | :--- |
| **Execution Speed** | Medium | Slow | **Fast (Native compiler)** |
| **Memory Footprint** | Moderate (~100MB) | Moderate (~120MB) | **Extremely Low (~15MB)** |
| **Concurrency Model** | Single-threaded Loop | Async/Await Event Loop | **Goroutines (M:N Scheduler)** |
| **Compile/Type Safety** | TypeScript (static check) | Type Hints | **Strict Static Typing** |

### Rationale
Go compiles into a single binary, starts instantly, and uses minimal RAM. Its standard library includes robust HTTP and network packages, reducing dependencies on third-party frameworks. Manually structured Clean Architecture directories keep code boundaries defined, allowing easy extraction of modules (e.g. real-time WebSockets) into separate services later.

---

## ADR 002: Search & Vector Database Selection

* **Status**: **Approved**
* **Context**: We need a storage system that can handle both keyword autocomplete searches and AI-driven vector similarity matching for candidate screening.
* **Alternatives Evaluated**:
  1. **Elasticsearch + Qdrant**: High performance, but requires running two separate database clusters, doubling DevOps overhead and cloud cost.
  2. **PostgreSQL (PGVector)**: Host vectors in Postgres, but complex vector queries block ACID transaction threads.
  3. **OpenSearch (Recommended)**: Combined search engine with native support for full-text lexical indexing and high-performance k-NN vector indexing.

### Trade-Off Comparison

| Metric | PGVector | Elasticsearch + Qdrant | OpenSearch |
| :--- | :--- | :--- | :--- |
| **DevOps Overhead** | Low | High | **Medium** |
| **Query Latency (Vector)**| High (under load) | Low | **Low** |
| **Lexical Autocomplete** | Poor | Excellent | **Excellent** |
| **Infrastructure Cost** | Free | High | **Medium (Unified cluster)** |

### Rationale
OpenSearch allows us to combine lexical search and vector search into a single cluster. It supports high-scale k-NN indexing (using cosine similarity on embeddings calculated by our Python AI microservice), enabling unified search query logic in the Go backend.

---

## ADR 003: Mobile UI Framework

* **Status**: **Approved**
* **Context**: We need to compile native mobile client applications for Android and iOS.
* **Alternatives Evaluated**:
  1. **React Native**: Uses JavaScript bridges that can stutter during heavy feed scrolling.
  2. **Flutter (Recommended)**: Compiled Dart code that renders at 60fps+ directly using native engine graphics.

### Rationale
Flutter compiles to native ARM instructions, avoiding bridge latency. Paired with Riverpod state management and GoRouter, it allows us to build a responsive, Material 3-compliant interface with consistent behavior across platforms.
