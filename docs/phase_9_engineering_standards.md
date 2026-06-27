# Phase 9: Engineering Standards & Git Guidelines

This document outlines the coding standards, folder layouts, and testing methodologies for the Go backend, Flutter mobile client, and Python AI microservices.

---

## 🐹 Go Backend Standards (Clean Architecture)

Our Go backend is structured using standard clean architecture patterns to keep code decoupled and testable:

```
cmd/
└── server/
    └── main.go                 # App entry point (initializes dependencies and starts server)
internal/
├── app/                        # Core application code
│   └── profiles/               # Example domain feature
│       ├── controller.go       # HTTP handler layer (parses DTOs and writes JSON)
│       ├── service.go          # Business logic domain layer (evaluates rules)
│       ├── repository.go       # Data access boundary layer (Postgres / SQL transactions)
│       └── model.go            # Domain database entities & tags
├── pkg/                        # Reusable internal packages
│   ├── database/               # PostgreSQL connection helper & pools
│   ├── middleware/             # HTTP authorization, CORS, and logging middlewares
│   └── search/                 # OpenSearch client wraps
└── config/                     # Configuration loaders (env parser structs)
```

### Go Coding Practices:
1. **Dependency Injection (DI)**: All dependencies (databases, repositories, services) are injected manually in `main.go` via constructors (e.g. `NewProfileService(repo)`). Global package variables or states are prohibited.
2. **Error Handling**: Never discard errors. Return wrapped errors up the call stack to logging boundaries:
   ```go
   if err != nil {
       return fmt.Errorf("failed to sync github profile: %w", err)
   }
   ```
3. **Structured Logging**: Use structured logging libraries like Go's standard library `slog` to write JSON to stdout:
   ```go
   slog.Error("github sync failed", "user_id", userID, "error", err)
   ```

---

## 📱 Flutter Mobile Standards (Feature-First)

To keep development modular, Flutter code uses a **Feature-First** layout with Clean Architecture separations inside each feature:

```
lib/
├── app/                        # Routing and global themes
├── common/                     # Global widgets and network clients
└── features/                   # Core business features
    └── jobs/                   # Example feature domain
        ├── data/               # API clients, local storage, DTOs
        │   ├── models/         # Freezed immutable data classes
        │   └── repositories/   # Repository implementation
        ├── domain/             # Entities & repository interfaces
        └── presentation/       # Riverpod providers, controllers, UI screens
```

### Flutter Coding Practices:
1. **Immutable Models**: All data models are defined using `freezed` to guarantee state immutability:
   ```dart
   @freezed
   class JobModel with _$JobModel {
     const factory JobModel({
       required String id,
       required String title,
       required String companyName,
     }) = _JobModel;
     factory JobModel.fromJson(Map<String, dynamic> json) => _$JobModelFromJson(json);
   }
   ```
2. **State Management**: Business state is managed via Riverpod's `Notifier` or `AsyncNotifier` structures. Direct UI state manipulations inside widgets are forbidden.

---

## 🐍 Python AI Standards (FastAPI & Pydantic)

AI services run inside an independent Python microservice designed using **FastAPI**:

```
app/
├── core/
│   ├── config.py               # Env configurations
│   └── security.py             # Internal API key validation guards
├── services/                   # LLM integrations
│   ├── rag_engine.py           # Context retrieval and synthesis
│   └── embedder.py             # LLM embedding creation wrappers
├── models/
│   └── schemas.py              # Pydantic validation schemas
└── main.py                     # FastAPI server instance
```

### Python Coding Practices:
1. **Pydantic Validation**: All input payloads and responses validate strictly against Pydantic schemas:
   ```python
   class CVAnalysisRequest(BaseModel):
       user_id: UUID4
       raw_text: constr(min_length=50)
   ```
2. **Async Operations**: I/O operations (network calls to LLMs, OpenSearch lookups) use async/await keywords to maximize service throughput:
   ```python
   async def generate_embedding(self, text: str) -> List[float]:
       ...
   ```
