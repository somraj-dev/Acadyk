# Phase 11: Security, Privacy & Compliance Matrix

This document defines the encryption standards, access control matrices, rate limiting models, fraud prevention rules, and GDPR compliance policies governing the Acadyk platform.

---

## 🔒 Session Security & Access Control

```
   ┌────────────────────────────────────────────────────────┐
   │                     Flutter Client                     │
   └───────────────┬────────────────────────┬───────────────┘
                   │ Access Token           │ Refresh Token
                   │ (Authorization Header) │ (HttpOnly, SameSite Cookie)
                   ▼                        ▼
   ┌────────────────────────────────────────────────────────┐
   │                Nginx / Go API Gateway                  │
   └────────────────────────┬───────────────────────────────┘
                            │ Validate Signature (RS256)
                            ▼
   ┌────────────────────────────────────────────────────────┐
   │               Go Route Handlers (RBAC/ABAC)            │
   └────────────────────────────────────────────────────────┘
```

### 1. Token Lifetime & Storage
* **Access Tokens**: JSON Web Tokens (JWT) signed via **RS256** asymmetric keys. Valid for **15 minutes**. Passed in the client request `Authorization: Bearer <token>` header.
* **Refresh Tokens**: Cryptographically secure random UUIDs stored in our Redis cache, mapping to user sessions. Passed to client via secure, `HttpOnly`, `Secure`, `SameSite=Strict` cookies. Valid for **7 days**.

### 2. Go JWT Middleware Implementation:
The Go backend interceptor checks JWT validity and context before allowing requests:

```go
package middleware

import (
	"context"
	"net/http"
	"strings"
	"github.com/golang-jwt/jwt/v5"
)

func JWTAuthMiddleware(jwtSecret []byte) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
				http.Error(w, "Unauthorized", http.StatusUnauthorized)
				return
			}

			tokenString := strings.TrimPrefix(authHeader, "Bearer ")
			token, err := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
				return jwtSecret, nil
			})

			if err != nil || !token.Valid {
				http.Error(w, "Unauthorized", http.StatusUnauthorized)
				return
			}

			claims, ok := token.Claims.(jwt.MapClaims)
			if !ok {
				http.Error(w, "Unauthorized", http.StatusUnauthorized)
				return
			}

			// Ingress Context injection
			ctx := context.WithValue(r.Context(), "user_id", claims["sub"])
			ctx = context.WithValue(ctx, "user_role", claims["role"])
			r = r.WithContext(ctx)

			next.ServeHTTP(w, r)
		})
	}
}
```

---

## 🛡️ Rate Limiting & Edge Protection

We implement rate limiting using **Redis** inside Go middleware to protect against brute-force attacks and scrape attempts:

```go
package middleware

import (
	"net/http"
	"github.com/redis/go-redis/v9"
)

func RateLimitMiddleware(rdb *redis.Client, limit int) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ip := r.RemoteAddr
			ctx := r.Context()

			// Increment request count in Redis with a sliding window
			count, err := rdb.Incr(ctx, ip).Result()
			if err == nil && count == 1 {
				rdb.Expire(ctx, ip, 60)
			}

			if err == nil && count > int64(limit) {
				http.Error(w, "Too Many Requests", http.StatusTooManyRequests)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
```

---

## 🔍 Fraud & GDPR Compliance Protocol

1. **DOI Vetting**: Go backend checks DOIs against CrossRef APIs to verify academic credentials.
2. **GDPR Account Deletion**: Account deletions run in a single transaction that cascades to delete Postgres profiles and triggers a secure event on the Redis queue, instructing the Python AI service to purge all matching vector documents in OpenSearch.
