# Acadyk Technical Debt Log

This log lists engineering shortcuts, code debt, and performance refactoring goals planned for execution as the system grows.

---

## 🪵 Tracked Debt Items

### TDB-001: Manual Go Dependency Injection
* **Status**: **Accepted (Temporary)**
* **Context**: For M1/M2, all Go structs (repositories, services, controllers) are manually initialized and injected in `cmd/server/main.go`.
* **Impact**: As features grow, `main.go` will grow to hundreds of lines of boilerplate setup.
* **Refactor Plan**: Once the backend surpasses 25 distinct modules, adopt **Google Wire** to generate type-safe dependency graph injection at build time.

### TDB-002: OpenSearch k-NN Vector Search Memory Consumption
* **Status**: **Accepted (Temporary)**
* **Context**: We store both textual documents and vector candidate profiles in a single shared OpenSearch cluster.
* **Impact**: HNSW vector index files must be loaded entirely in RAM to keep latency low, which can starve standard text indexing of cache space.
* **Refactor Plan**: In M3/M4, configure dedicated **search-only data nodes** inside the OpenSearch cluster specifically to host vector segments, separating them from lexical logs indexing.

### TDB-003: Postgres Database Connection Exhaustion
* **Status**: **Accepted (Temporary)**
* **Context**: The Go backend utilizes concurrent goroutines to handle HTTP and WebSocket queries, making database calls.
* **Impact**: Under heavy spikes, Go can spin up thousands of database connections, exhausting PostgreSQL connection limits.
* **Refactor Plan**: Limit connection pools inside Go (`SetMaxOpenConns` settings) and deploy **PgBouncer** connection pool managers in front of the PostgreSQL instance in M3.
