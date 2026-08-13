# Phase 6: Core Product Modules Specification

This document details the functional specifications, API requirements, and database dependencies for the primary architectural modules of the Acadyk ecosystem, aligned with the Go and Python AI stack.

---

## 🔐 Module Group 1: Identity & Profiles
*Encompasses Authentication, User Profiles, Organization Profiles, and Institute Profiles.*

### 1. Purpose & User Stories
* **Purpose**: Establish secure identity credentials, manage institutional roles, and aggregate user portfolios (GitHub, ORCID, LinkedIn, University SSOs).
* **User Story**: *As a student, I want to authenticate via my university SSO or GitHub account so that my credentials and projects link instantly to my profile.*

### 2. Core Go API Endpoints
* `POST /api/v1/auth/register` (Register user - returns JWT)
* `POST /api/v1/auth/oauth/github` (Authenticate/link GitHub token)
* `GET /api/v1/profiles/:userId` (Fetch profile metadata & integrations)
* `PUT /api/v1/profiles/skills` (Update skill arrays - updates GIN index)

### 3. Go Backend Validation Schema (using Go tags):
```go
type RegisterRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=8"`
	Role     string `json:"role" validate:"required,oneof=Learner Creator Researcher Recruiter"`
}
```

---

## 💬 Module Group 2: Social & Messaging
*Encompasses Feed, Posts, Comments, Reactions, Messaging, and Notifications.*

### 1. Purpose & User Stories
* **Purpose**: Facilitate knowledge-sharing, peer reviews, direct conversations, and real-time push alerts.
* **User Story**: *As a developer, I want to share a code snippet, receive comments, and get real-time WebSocket notifications when someone replies.*

### 2. Core API & WebSocket Endpoints
* `GET /api/v1/feed` (Fetch ranked post feed - cached in Redis)
* `POST /api/v1/posts` (Create new post - triggers `PostCreated` event)
* `POST /api/v1/posts/:postId/reactions` (React with heart, code-like, star)
* WebSocket connection: `/api/v1/ws` (Upgrade to WebSocket protocol using `gorilla/websocket`)
  * Broadcast payload: `{"type": "message", "to": "user-uuid", "body": "text"}`

---

## 💼 Module Group 3: Talent & Hiring
*Encompasses Jobs, Hiring Portal, and Professional Events.*

### 1. Purpose & User Stories
* **Purpose**: Connect vetted talent with corporate and startup hiring pipelines.
* **User Story**: *As a recruiter, I want to search for candidates who completed a React course and have pushed actual code repositories, screen them, and transition them through an ATS funnel.*

### 2. Core API Endpoints
* `POST /api/v1/jobs` (Post job vacancy - Recruiter only)
* `GET /api/v1/jobs/match` (Fetch AI-suggested job matches for user profile)
* `POST /api/v1/jobs/:jobId/apply` (Submit resume, GitHub analytics snapshot)
* `PATCH /api/v1/hiring/applications/:appId` (Update candidate pipeline status)

---

## 🎓 Module Group 4: Learning & Research
*Encompasses Courses, Learning Modules, and Academic Research (Preprints/ORCID).*

### 1. Purpose & User Stories
* **Purpose**: Delivery of certified educational content and tracking academic contributions.
* **User Story**: *As a researcher, I want to upload my research preprint, associate it with a code repository, and request a peer review from verified professors on the platform.*

### 2. Core API Endpoints
* `GET /api/v1/courses` (Fetch active courses list)
* `POST /api/v1/courses/:courseId/enroll` (Register enrollment)
* `POST /api/v1/research/publications` (Publish preprint, attach DOI & Git repo link)
* `POST /api/v1/research/reviews` (Submit peer review report)

---

## 🤖 Module Group 5: AI Assistant & Search
*Encompasses AI Career Assistant, Resume Parser, and Vector Match.*

### 1. Purpose & User Stories
* **Purpose**: LLM-driven recommendation engines, chatbot guidance, resume audits, and vector alignment.
* **User Story**: *As a learner, I want to ask the AI coach to run a mock coding interview based on my GitHub profile and active courses.*

### 2. Core API Endpoints (Proxied securely from Go monolith to Python microservice)
* `POST /api/v1/ai/career-chat` (Submit message to RAG career agent)
* `POST /api/v1/ai/analyze-resume` (Submit PDF for CV review)
* `GET /api/v1/ai/candidates/semantic-search` (Recruiter query endpoint)
