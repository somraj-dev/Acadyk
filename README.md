# Acadyk — Production Enterprise Monorepo

Acadyk is an enterprise academic, professional, and career discovery network built with **Flutter (Mobile)** and **Kotlin Spring Boot 3.3.x (Enterprise Core Backend)**.

---

## 🏗 Repository Structure

```
Acadyk/
├── apps/
│   └── mobile/                  # Flutter Mobile Application (Android & iOS)
│       ├── android/
│       ├── ios/
│       ├── assets/
│       ├── lib/
│       │   ├── app/
│       │   ├── common/
│       │   ├── core/
│       │   └── features/        # 17 Feature-First Clean Architecture Packages
│       ├── integration_test/
│       ├── test/
│       ├── pubspec.yaml
│       └── analysis_options.yaml
│
├── backend/
│   └── acadyk-api/              # Kotlin + Spring Boot Enterprise Core
│       ├── src/
│       │   ├── main/
│       │   │   ├── kotlin/com/acadyk/
│       │   │   │   ├── AcadykApplication.kt
│       │   │   │   ├── config/
│       │   │   │   ├── security/
│       │   │   │   ├── common/
│       │   │   │   ├── infrastructure/
│       │   │   │   │   ├── fcm/
│       │   │   │   │   ├── kafka/
│       │   │   │   │   ├── redis/
│       │   │   │   │   ├── s3/
│       │   │   │   │   └── websocket/
│       │   │   │   └── modules/ (17 Domain Modules)
│       │   │   └── resources/
│       │   │       ├── application.yml
│       │   │       └── db/migration/ (13 Ordered Flyway SQL Migrations)
│       │   └── test/
│       ├── build.gradle.kts
│       ├── settings.gradle.kts
│       └── Dockerfile
│
├── database/
│   └── migrations/              # Flyway SQL Source Migrations (V1 to V13)
│
├── infrastructure/              # Cloud, Observability & Containerization
│   ├── docker/
│   ├── aws/
│   └── monitoring/
│
├── docs/                        # Architecture & Database ERD Specifications
├── docker-compose.yml           # Local Infrastructure Stack (PostgreSQL, Redis, Kafka, ES)
├── .env.example                 # Environment Variable Definitions
├── Makefile                     # Monorepo Task Automation
└── README.md                    # Project Documentation
```

---

## 🚀 Tech Stack

### 📱 Frontend (Mobile)
- **Framework**: Flutter & Dart (100% UI preservation across 50+ screens)
- **Architecture**: Feature-First Clean Architecture
- **State Management**: Riverpod & Provider (`AsyncState<T>`)
- **Networking**: Dio (HTTP) & Resilient STOMP WebSockets (with exponential backoff)
- **Authentication**: Firebase Authentication SDK + `flutter_secure_storage`

### ⚙️ Backend (Core API)
- **Language & Runtime**: Kotlin (JDK 21) + Spring Boot 3.3.x
- **Security**: Spring Security + Firebase Admin SDK Token Filter + RBAC (`STUDENT`, `FACULTY`, `COLLEGE_ADMIN`, `COMPANY`, `MODERATOR`, `SUPER_ADMIN`)
- **Primary Database**: PostgreSQL (ACID transactional source of truth) with 13 Flyway SQL migrations
- **Caching & Concurrency**: Redis (Cache-aside, sliding-window rate limiting, atomic distributed locks)
- **Message Broker & Events**: Apache Kafka (Strongly-typed domain events for decoupled async fanout)
- **Search Engine**: Elasticsearch (7 search projections with autocomplete & typo tolerance)
- **Object Storage**: AWS S3 (Pre-signed upload/download URLs & IAM least-privilege policies)
- **Push Notifications**: Firebase Cloud Messaging (FCM) with fine-grained user preference checks

---

## ⚡ Quick Start

### 1. Prerequisites
- **Flutter SDK** (v3.22.x or higher)
- **Java JDK 21**
- **Docker & Docker Compose**

### 2. Launch Local Infrastructure
```bash
docker-compose up -d postgres redis kafka elasticsearch
```

### 3. Run Backend API
```bash
cd backend/acadyk-api
./gradlew bootRun
```

### 4. Run Mobile Application
```bash
cd apps/mobile
flutter pub get
flutter test
flutter run
```

---

## 🧪 Testing

Run the full automated test suite:
```bash
make test
# 00:01 +5: All tests passed!
```
