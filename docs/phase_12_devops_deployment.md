# Phase 12: DevOps, Deployment & Infrastructure

This document details the CI/CD deployment pipelines, container configurations, Kubernetes scaling targets, and disaster recovery schemas for the Go backend and Python AI microservices.

---

## 🐋 Containerization (Docker Configurations)

### 1. Go Backend Monolith Dockerfile
We build a statically compiled Go binary on an Alpine environment and copy it to a minimal scratch container, reducing the final image size to ~30MB.

```dockerfile
# Stage 1: Build & Compile Go Binary
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main cmd/server/main.go

# Stage 2: Clean Production Runtime
FROM alpine:latest
WORKDIR /app
RUN apk --no-cache add ca-certificates
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
```

### 2. Python AI Microservice Dockerfile
We install Python dependencies into a virtual environment in the build stage and copy the environment to a slim python runtime image, keeping image sizes small (~180MB).

```dockerfile
# Stage 1: Build virtual environment
FROM python:3.11-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends build-essential
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime image
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 📦 Kubernetes (EKS) Orchestration

The Go and Python services deploy to separate pods on AWS EKS behind an NGINX Ingress controller.

### 1. Go Backend Deployment Snip:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: acadyk-go-backend
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: go-backend
  template:
    metadata:
      labels:
        app: go-backend
    spec:
      containers:
      - name: go-app
        image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/go-backend:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            cpu: "500m"
            memory: 512Mi
          requests:
            cpu: "250m"
            memory: 256Mi
```

### 2. Python AI Service Deployment Snip:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: acadyk-py-ai-service
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: py-ai-service
  template:
    metadata:
      labels:
        app: py-ai-service
    spec:
      containers:
      - name: py-ai-app
        image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/py-ai-service:latest
        ports:
        - containerPort: 8000
        resources:
          limits:
            cpu: "1000m"
            memory: 1024Mi
          requests:
            cpu: "500m"
            memory: 512Mi
```
