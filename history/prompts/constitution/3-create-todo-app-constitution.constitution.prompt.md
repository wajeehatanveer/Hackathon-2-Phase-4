---
id: 3
title: Create-Todo-App-Constitution
stage: constitution
date: 2026-01-03
surface: agent
model: Qwen
feature: todo-app
branch: main
user: hp
command: /sp.constitution
labels: [constitution, todo-app, spec-driven]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
 - .specify/memory/constitution.md
 - .specify/templates/plan-template.md
 - .specify/templates/spec-template.md
 - .specify/templates/tasks-template.md
tests:
 - null
---

## Prompt

```text
/sp.constitution Full stack web application for the Evolution of Todo- Hackathon Phase II.

  Project Name:
  Todo App

  Project Goal:
  Create full Stack todo application in a modern, multi-user, full-stack web application using a spec-driven development approach.

  High-Level Description:
  This project is a monorepo-based full-stack todo application consisting of:
  - A Next.js frontend
  - A FastAPI backend
  - SQLModel ORM
  - Neon Serverless PostgreSQL database
  - JWT-based authentication using Better Auth

  The application must support multiple users, persistent storage, secure authentication, and strict user data isolation.

  Current Phase:
  Phase II – Todo Full-Stack Web Application

  Core Functional Scope:
  - Implement all basic todo features as a web application:
    - Create task
    - List tasks
    - View task details
    - Update task
    - Delete task
    - Toggle task completion
  - Convert console-based logic into RESTful APIs
  - Build a responsive frontend UI
  - Persist data in Neon PostgreSQL
  - Secure all APIs using JWT authentication

  Technology Stack (Mandatory):
  Frontend:
  - Next.js 16+ (App Router)
  - TypeScript
  - Tailwind CSS

  Backend:
  - Python FastAPI
  - SQLModel ORM

  Database:
  - Neon Serverless PostgreSQL

  Authentication:
  - Better Auth (runs on frontend)
  - JWT-based authentication
  - Shared secret via environment variable BETTER_AUTH_SECRET

  Architecture Principles:
  - Monorepo structure with separate frontend and backend folders
  - Spec-driven development using Spec-Kit Plus
  - All implementation must strictly follow specs located in /specs
  - Specs are the single source of truth

  Security & Authentication Rules:
  - All backend endpoints require a valid JWT token
  - JWT is issued by Better Auth on the frontend
  - Backend must independently verify JWT
  - Requests without JWT must return 401 Unauthorized
  - Invalid or expired JWT must return 401 Unauthorized
  - User data must be fully isolated
  - A user can access only their own tasks
  - user_id in URL must always match user_id from JWT payload

  API Design Rules:
  - All APIs must be RESTful
  - All routes must be prefixed with /api/
  - Supported methods: GET, POST, PUT, DELETE, PATCH
  - APIs must follow specs in @specs/api/rest-endpoints.md
  - Responses must be JSON
  - Errors must be handled using proper HTTP status codes

  Database Rules:
  - Use SQLModel for all database operations
  - Database schema must follow @specs/database/schema.md
  - All task queries must be filtered by authenticated user_id
  - No cross-user data access under any circumstance

  Spec-Kit Usage Rules:
  - Always read relevant spec before implementing
  - Reference specs using @specs/... syntax
  - Do not invent features outside the specs
  - If a requirement is unclear, defer to the spec files

  QWEN Operating Rules:
  - Treat this constitution as authoritative
  - All agents, skills, and code must comply with this constitution
  - Do not violate architectural, security, or spec-driven constraints
  - Do not implement future phases (e.g., chatbot) in Phase II
  - Focus strictly on Phase II scope

  Outcome Expectation:
  A secure, spec-compliant, production-ready full-stack todo web application that passes hackathon Phase II requirements.
```

## Response snapshot

I've created the project constitution for the Todo App based on your requirements. The constitution includes:

1. Six core principles:
   - Spec-Driven Development (NON-NEGOTIABLE)
   - Full-Stack Architecture
   - Security-First Approach (NON-NEGOTIABLE)
   - RESTful API Design
   - Type Safety and Validation
   - Data Persistence and Isolation

2. Additional constraints section covering the technology stack and requirements

3. Development workflow section outlining the spec-driven approach

4. Governance section with versioning and compliance information

The constitution has been written to the file `.specify/memory/constitution.md` with version 1.0.0, ratified on 2026-01-03.

## Outcome

- ✅ Impact: Created comprehensive constitution for Todo App project with all specified requirements
- 🧪 Tests: No tests needed for constitution creation
- 📁 Files: Created .specify/memory/constitution.md
- 🔁 Next prompts: Ready for spec creation based on this constitution
- 🧠 Reflection: Constitution aligns with all specified architectural and security requirements

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): N/A
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Begin creating feature specifications based on this constitution