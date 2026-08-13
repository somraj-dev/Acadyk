# Phase 2: Product Strategy & Monetization

This document outlines the Minimum Viable Product (MVP) specification, feature prioritization roadmap, monetization strategies, B2C/B2B pricing plans, user journeys, and growth engine.

---

## 🚀 MVP Definition & Prioritization

To avoid overengineering a complex ecosystem early, we partition our roadmap into four distinct priority tiers. The MVP will focus solely on establishing a **verified identity** and **connecting talent to opportunities**.

### Feature Prioritization Matrix (MoSCoW)

```
┌─────────────────────────────────────────┐
│              MVP (Must Have)            │
├─────────────────────────────────────────┤
│ • Social profile integration (GitHub,   │
│   ORCID, Google, Edu SSO)               │
│ • Unified Profile (Dev + Academic)      │
│ • Basic Feed & Post system              │
│ • Direct Messaging & Communities        │
│ • Job Board & Quick Apply               │
│ • AI Resume & Skill Analysis (RAG)      │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│            Phase 2 (Should Have)        │
├─────────────────────────────────────────┤
│ • LMS & Course Delivery (LTI standard)  │
│ • Real-time WebSockets Messaging        │
│ • Startup Incubator Portal              │
│ • Institutional Admin & Analytics       │
│ • Automated Peer Review for Research    │
└────────────────────┬────────────────────┘
                     │
┌────────────────────▼────────────────────┐
│            Phase 3 (Could/Won't Have)   │
├─────────────────────────────────────────┤
│ • Built-in IDE for coding assessments   │
│ • Video conferencing for classes/interv │
│ • Multi-tenant university whitelist SSO │
│ • Crypto/Web3 micro-grants for R&D      │
└─────────────────────────────────────────┘
```

---

## 👤 User Journeys (Core Loops)

### Loop 1: The Dev-Learner to Employment Loop
1. **Acquisition**: A computer science student notices a "Verify on Acadyk" badge on a popular GitHub repository.
2. **Onboarding**: Signs up via GitHub OAuth. Acadyk imports their repositories, analyzes languages used, commits made, and popular stars.
3. **Skill Gap Discovery**: User asks the AI Career Assistant: *"How do I qualify for a senior React role?"*
4. **Learning**: AI analyzes their Git history, flags a lack of state management experience, and suggests an Acadyk mini-course on Redux/Zustand.
5. **Validation**: The student completes the course, builds a mini-project (pushed to Git), and updates their profile.
6. **Conversion**: A recruiter using Acadyk's candidate vector search filters for React developers with verified state-management repositories. The student's profile matches; the recruiter initiates a conversation.

### Loop 2: The Academic Research to Incubation Loop
1. **Acquisition**: A graduate student publishes a preprint on a research portal.
2. **Import**: The researcher logs in with ORCID. Acadyk ingests the metadata and parses the paper with LLM extraction.
3. **Collaboration**: The system identifies that this research utilizes machine learning optimization techniques, matching it to an active startup in the Acadyk Incubator seeking technical advisors.
4. **Matching**: The system automatically drafts a collaboration invite, connecting the researcher to the startup co-founders.

---

## 💰 Monetization Strategy & Pricing Plans

Acadyk operates on a hybrid B2C/B2B freemium model. Networking is free, but high-value hiring, credentialing, and advanced workflow utilities are monetized.

```
                         ┌───────────────────────────┐
                         │   Monetization Engines    │
                         └─────────────┬─────────────┘
         ┌─────────────────────────────┼─────────────────────────────┐
┌────────▼────────┐           ┌────────▼────────┐           ┌────────▼────────┐
│  B2C Subscriptions         │ B2B Recruitment │           │ B2B SaaS (LMS)  │
│  - Free Network │           │ - Candidate Search        │ - White-Label   │
│  - Premium CV   │           │ - ATS Integration         │ - Alumni CRM    │
└─────────────────┘           └─────────────────┘           └─────────────────┘
```

### 1. B2C Personal Plans
* **Free Tier ($0)**
  * Basic Profile with 1 portfolio integration (GitHub, LinkedIn, or ORCID).
  * Access to public feeds and communities.
  * Apply to 10 jobs/month.
  * Basic AI resume parsing (1 analysis/month).
* **Acadyk Pro ($12 / month)**
  * Unlimited portfolio integrations.
  * Verifiable Profile Badge (checks activity metadata).
  * Unlimited job applications.
  * Interactive AI Career Assistant (unlimited mock interviews, code critique).
  * Priority candidate sorting in recruiter views.

### 2. B2B Recruiter & Corporate Plans
* **Acadyk Talent ($99 / user / month)**
  * Semantic Candidate Search (natural language queries like: *"Find me a developer who has contributed to PyTorch and understands GANs"*).
  * Automated Vetting (AI matches candidate Git repositories & papers to job descriptions, returning a verified match score).
  * 100 direct candidate messages/month (InMail equivalent).
  * Standard ATS integration (Workday, Greenhouse).

### 3. B2B Institutional SaaS (Universities & Incubators)
* **Acadyk Campus (Custom Enterprise Quote — e.g., $2,000 to $10,000 / year)**
  * White-labeled portal for students, faculty, and alumni.
  * Custom LMS & LTI integrations (Canvas, Blackboard).
  * Placement Office Dashboard: track student employment pipelines, resume books, and job placement statistics.
  * Dedicated Incubator Module: manage applications, cap tables, mentor match-making, and seed-fund distribution.

---

## 📈 Growth Strategy (Viral Loops & SEO)

1. **The GitHub README Badge**:
   Encourage developers to embed dynamic SVG badges in their GitHub profile readmes (e.g., `![Acadyk Profile](https://api.acadyk.com/badge/username)`). This serves as a high-signal backlink and traffic generator.
2. **Programmatic SEO (Academic & Code Index)**:
   We index public preprints, publications, and open-source project structures, creating SEO-optimized landing pages for technologies and research fields. Searching for *"Optimized transformer models for NLP on edge devices"* indexes Acadyk research profiles and projects on Google search results.
3. **Institution-Led Onboarding**:
   By partnering with university placement offices, we onboard entire graduating classes in single actions. The university mandates profile creation to coordinate graduation placement books, bootstrapping high-quality talent cohorts.
4. **Shared Achievements Loop**:
   When users complete a skill certificate or publish a paper, Acadyk generates a highly polished, shareable image preview optimized for Twitter, LinkedIn, and email, with QR links pointing back to their verified profile.
