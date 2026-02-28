# Implementation Plan: AI Todo Chatbot Integration

**Branch**: `001-ai-chatbot-integration` | **Date**: 2026-02-17 | **Spec**: [specs/001-ai-chatbot-integration/spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-ai-chatbot-integration/spec.md`

## Summary

**Primary Requirement**: Enable natural language task management through a conversational chatbot interface, allowing users to create, list, update, complete, and delete tasks using everyday language instead of forms and buttons.

**Technical Approach**: Implement a Cohere-powered AI reasoning layer that interprets natural language input, extracts intent and parameters, invokes MCP tools for database operations, and returns contextual natural language responses. The system uses a stateless FastAPI backend with JWT authentication, Neon PostgreSQL for conversation persistence, and a Next.js frontend with a slide-in chat panel.

## Technical Context

**Language/Version**: Python 3.11 for backend, TypeScript 5.x for frontend
**Primary Dependencies**: FastAPI, SQLModel, Cohere Python client, Next.js 16+, Better Auth
**Storage**: Neon Serverless PostgreSQL
**Testing**: pytest for backend, Jest/React Testing Library for frontend
**Target Platform**: Web application (cross-browser)
**Project Type**: Web application with frontend + backend
**Performance Goals**: p95 <500ms for chat endpoint, <100ms DB queries, 1000+ concurrent users
**Constraints**: <2s response time (excluding AI latency), stateless backend, JWT auth on all requests
**Scale/Scope**: Hackathon demo scale with production-ready architecture

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Gate 1: Conversational Task Management
**Requirement**: All 5 task operations accessible via natural language
**Status**: ✅ PASS
**Justification**: MCP tools (add_task, delete_task, update_task, mark_complete, list_tasks) cover all Phase II functionality. Cohere API parses natural language and invokes appropriate tools.

### Gate 2: AI-First Interface
**Requirement**: Cohere API for all reasoning, no OpenAI
**Status**: ✅ PASS
**Justification**: System uses Cohere chat endpoint exclusively. Tool-calling simulated via structured prompting and JSON parsing. No OpenAI dependencies.

### Gate 3: Stateless Architecture
**Requirement**: No server session state, DB persistence only
**Status**: ✅ PASS
**Justification**: Backend maintains no conversation state. All state persisted via Conversation and Message models in PostgreSQL. Horizontal scaling supported.

### Gate 4: Security & Isolation
**Requirement**: JWT validation, user_id scoping on all operations
**Status**: ✅ PASS
**Justification**: Better Auth JWT enforced on all endpoints. User ID extracted from JWT and validated on every tool call. Database queries scoped by user_id.

### Gate 5: Test-First
**Requirement**: Contract tests for all MCP tools before implementation
**Status**: ✅ PASS
**Justification**: Contract tests defined in contracts/mcp-tools.yaml. Unit and integration tests written before tool implementation per Constitution Principle III.

### Gate 6: Database Extensions
**Requirement**: Conversation + Message models with proper indexes
**Status**: ✅ PASS
**Justification**: New models extend Phase II schema with user_id isolation. Indexes on user_id, conversation_id, and created_at ensure <100ms query performance.

## Project Structure

### Documentation (this feature)

```text
specs/001-ai-chatbot-integration/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── chat-api.yaml
│   └── mcp-tools.yaml
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
backend/
├── src/
│   ├── models/
│   │   ├── task.py
│   │   ├── user.py
│   │   ├── conversation.py
│   │   └── message.py
│   ├── api/
│   │   ├── tasks.py
│   │   ├── auth.py
│   │   └── chat.py
│   ├── mcp/
│   │   ├── server.py
│   │   └── tools/
│   │       ├── add_task.py
│   │       ├── delete_task.py
│   │       ├── update_task.py
│   │       ├── mark_complete.py
│   │       └── list_tasks.py
│   └── services/
│       ├── cohere_service.py
│       └── auth_service.py
└── tests/
    ├── contract/
    ├── integration/
    └── unit/

frontend/
├── src/
│   ├── components/
│   │   └── Chat/
│   │       ├── ChatWindow.tsx
│   │       ├── MessageList.tsx
│   │       └── MessageInput.tsx
│   └── pages/
│       └── chat.tsx
└── tests/
```

**Structure Decision**: Option 2 (Web application) selected. Backend and frontend directories already exist from Phase II. New chatbot functionality extends existing structure with dedicated MCP tools directory and Chat components.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No constitution violations. All gates passed.*
