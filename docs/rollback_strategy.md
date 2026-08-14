# Acadyk Production Rollback Strategy & Protocol

## 1. Overview
This document outlines standard operating procedures (SOP) for automated and manual rollbacks across all production tiers:
1. Database Migrations (PostgreSQL & Flyway)
2. Backend Microservices (Docker & Kubernetes/ECS)
3. Infrastructure & Cache (Redis, Kafka, Elasticsearch)
4. Mobile Applications (Flutter Android / iOS)

---

## 2. Database Migration Rollback Protocol

### 2.1 Backward-Compatible Migration Rule
All Flyway migrations (`V1` to `V13`) follow the **Expand-Contract Pattern**:
- **Expand Phase**: Add new columns/tables with nullable or default values so old and new backend versions operate simultaneously.
- **Contract Phase**: Drop deprecated columns only after 100% of traffic is confirmed stable on the new version.

### 2.2 Reverting a Failed Migration
If a migration fails during deployment:
1. Identify the failed version in `flyway_schema_history`:
   ```sql
   SELECT version, description, success FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;
   ```
2. If `success = false`, repair schema history:
   ```bash
   ./gradlew flywayRepair
   ```
3. Apply targeted rollback DDL script located in `database/rollback/U<version>__rollback.sql`.

---

## 3. Backend Microservice Rollback

### 3.1 Docker Compose / ECS Rollback
To immediately roll back to the previous stable release container:
```bash
# Set image tag to previous known-stable commit SHA
export IMAGE_TAG=3e8abdfdcfe45c82a3d959e218f03779910f8674
docker compose -f docker-compose.prod.yml up -d --no-deps acadyk-api
```

### 3.2 Automated Healthcheck Rollback Hook
The production container healthcheck periodically queries:
```
GET /actuator/health
```
If 3 consecutive healthchecks fail within the 30-second start window, the orchestrator halts traffic forwarding and keeps the previous container instance active.

---

## 4. Cache & Event Stream Rollback

### 4.1 Redis Cache Purge
If cached feed or metadata formats are incompatible with the rolled-back version:
```bash
# Invalidate affected cache keys
redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD KEYS "feed:*" | xargs redis-cli -a $REDIS_PASSWORD DEL
```

### 4.2 Kafka Consumer Offset Rewind
If an event consumer crashed due to malformed events:
```bash
# Rewind consumer group to previous committed timestamp
kafka-consumer-groups.sh --bootstrap-server $KAFKA_BROKERS \
  --group acadyk-consumer-group \
  --reset-offsets --to-offset <SAFE_OFFSET> \
  --topic acadyk.post.events --execute
```

---

## 5. Mobile App Rollback (Flutter)

1. **Feature Flags & Remote Config**: Critical UI flows contain remote feature toggles that disable or fallback newly introduced screens instantly without requiring app store resubmission.
2. **API Versioning**: All mobile REST requests use `/api/v1/...`. When backward-incompatible changes are deployed, a parallel `/api/v2/...` route is introduced, ensuring older installed mobile app versions remain 100% functional.
