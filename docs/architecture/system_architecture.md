# Acadyk System Architecture Specifications

## 1. High-Level Technology Stack

Acadyk is an enterprise social & portfolio platform built with:
- **Mobile Client**: Flutter 3.29.x, Clean Architecture, Riverpod, GoRouter, Dio HTTP/2 client, WebSocket STOMP.
- **Backend Service**: Kotlin 1.9.24, Spring Boot 3.3.x, Spring Security, Spring Data JPA.
- **Primary Data Store**: Relational PostgreSQL 16 managed with Flyway migrations (`V1` to `V13`).
- **Distributed Cache & Locking**: Redis 7 for cache-aside patterns, rate limiting, and distributed locking.
- **Event Streaming**: Apache Kafka (KRaft mode) for asynchronous domain events.
- **Search Engine**: Elasticsearch 8 with 7 specialized entity indices, typo tolerance, and database fallback.
- **Object Storage**: AWS S3 with IAM least privilege and pre-signed upload/download URLs.
- **Push Notification Pipeline**: Firebase Cloud Messaging (FCM) dispatch coupled with in-app notification history.
- **Authentication**: Firebase Authentication ID Token verification via Spring Security filter.
