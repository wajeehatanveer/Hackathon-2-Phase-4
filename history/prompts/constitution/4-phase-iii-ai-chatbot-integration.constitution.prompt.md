---
id: 4
title: Phase-III-AI-Chatbot-Integration
stage: constitution
date: 2026-02-16
surface: agent
model: Qwen
feature: ai-chatbot-integration
branch: main
user: hp
command: /sp.constitution AI Todo Chatbot Integration for The Evolution of Todo - Phase III
labels: [constitution, phase-iii, ai-chatbot, cohere, mcp-tools]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
 - .specify/memory/constitution.md
tests:
 - null
---

## Prompt

```text
/sp.constitution AI Todo Chatbot Integration for The Evolution of Todo - Phase III: Full-Stack Web Application 

Target audience: Hackathon judges evaluating cutting-edge agentic AI integrations, developers building intelligent productivity tools, and AI agents (Claude Code) implementing via Spec-Kit Plus in a monorepo.

Focus: Create a comprehensive, authoritative constitution that seamlessly integrates a powerful AI-powered chatbot into the existing Phase II full-stack backend (FastAPI + Neon DB + Better Auth). The chatbot must handle all core task functionalities (add, delete, mark complete, update, list) through natural language, provide user email info from the logged-in session, and offer full conversational control. Replace OpenAI Agents SDK with Cohere's API for AI logic — adapt any agent-like code to use Cohere's chat/completions endpoint for tool calling and reasoning. This document serves as the foundational governance for Phase III, ensuring stateless architecture, MCP tools for task operations, and persistent conversation state in the database.

Success criteria:
• Defines a chatbot with full functionality: natural language task management (CRUD + complete), user email queries (e.g., "Who am I?" → "Logged in as example@email.com"), confirmations, error handling, and graceful responses.
• Integrates seamlessly into existing backend: single stateless /api/{user_id}/chat endpoint, MCP tools exposed, Cohere API for AI reasoning/tool invocation.
• Adapts OpenAI-style agent behavior to Cohere API: use Cohere's chat endpoint for multi-turn conversations with tool calls.

conversations with tool calls.
• Ensures multi-user security: JWT auth for user_id, task isolation, conversation persistence per user.
• Generates a complete Markdown file (constitution.md) version v3.0 placed at repository root — ready to guide all Phase III specs, plans, agents, and implementations.
• Resulting chatbot feels intelligent, helpful, and production-ready: handles complex queries (e.g., "Add weekly meeting and list pending tasks") by chaining tools.

Constraints:
• Format: Markdown with deeply structured sections (Project Overview, Core Requirements, Chatbot Functionality & Natural Language Handling, Authentication & Security, Non-Functional Requirements, Technology Stack and Tools, Development Workflow, Monorepo Updates, Database Extensions, MCP Tools Specification, Cohere API Adaptation, Guiding Principles, Deliverables and Success Criteria).
• Version: v3.0 (Phase III), include current date (January 06, 2026).
• Strictly integrate into existing monorepo: extend /backend with MCP server and chat endpoint; add ChatKit to /frontend if needed.
• Dependencies limited to: Existing stack (FastAPI, SQLModel, Neon PostgreSQL, Better Auth) + Cohere API (for AI chat/completions), Official MCP SDK (for tools) + ...
• Cohere Adaptation: Use Cohere's API key for all AI calls; no additional frameworks/prompts to reason. Simulate agent/tool-calling by structuring prompts to reason step-by-step and output tool invocation JSON.
• Stateless: No server state — persist conversations/messages in DB.
• No manual coding: All via Claude Code agents/skills.
• Keep concise yet exhaustive (under 3000 words).
• Reference Phase I/II briefly as completed foundation.

Specific Sections Required:
1. Project Overview – Summarize evolution to AI chatbot, objective: natural language task management with full functionality.
2. Core Requirements – Conversational interface for 5 basic features, user email queries, stateless endpoint.
3. Chatbot Functionality & Natural Language Handling – Detail flows, examples (e.g., "Add task" → add_task tool), confirmations, errors.
4. Authentication & Security – JWT for user_id/email extraction, isolation in tools/conversations.
5. Non-Functional Requirements – Clean code, async ops, scalability, graceful errors.
6. Technology Stack and Tools – Extend Phase II: Cohere API for AI, MCP SDK for tools, ChatKit frontend.
7. Development Workflow – Agentic: spec → plan → tasks → Claude Code; Cohere API key usage.
8. Monorepo Updates – Extend structure: add chatbot routes, DB models (Conversation, Message).
9. Database Extensions – New models: Conversation (user_id, id), Message (conversation_id, role, id, content).
10. MCP Tools Specification – Exact 5 tools with params/returns, stateless DB interaction.
11. Cohere API Adaptation – Detail tools with params/returns, stateless DB interaction. Detail how to adapt agent logic: prompt Cohere for reasoning/tool calls, parse JSON output.
12. Guiding Principles – AI-first, stateless, security, no manual code, hackathon transparency.
13. Deliverables and Success Criteria – Working chatbot, repo updates, demo: natural queries handled.

Environment Variables:
• COHERE_API_KEY=XkGIm4JCe7Iajv5FrGpxNHYZrhhmXu0ilcnj0(for AI calls) 
• Use existing BETTER_AUTH_SECRET, DATABASE_URL.

Generate immediately — this constitution must guarantee a seamless, intelligent, error-free chatbot integration that elevates the full-stack app to flagship AI status. Perfection in every detail.
```

## Response snapshot

Created comprehensive Phase III constitution (v3.0.0) with:
- 9 core principles covering conversational task management, MCP tools, stateless architecture, Cohere API adaptation, and security
- Detailed monorepo structure updates for backend (models, API, MCP tools, services) and frontend (Chat components)
- Database extensions: Conversation and Message models with proper indexing
- Complete MCP tools specification: add_task, delete_task, update_task, mark_complete, list_tasks
- Cohere API adaptation guide with tool-calling simulation flow
- Sync impact report tracking version change from 2.0.0 → 3.0.0
- All templates validated for compatibility

## Outcome

- ✅ Impact: Upgraded constitution from v2.0.0 to v3.0.0 with 9 principles, 4 new sections added (AI-First, Database Extensions, MCP Tools, Cohere Adaptation, Security)
- 🧪 Tests: No tests needed for constitution creation
- 📁 Files: Updated .specify/memory/constitution.md
- 🔁 Next prompts: Ready for /sp.spec to create chatbot feature specification
- 🧠 Reflection: Constitution maintains Phase II foundation while adding AI chatbot layer with strict stateless architecture and security requirements

## Evaluation notes (flywheel)

- Failure modes observed: None - constitution creation successful
- Graders run and results (PASS/FAIL): N/A
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Begin Phase III spec creation with /sp.spec command focusing on user stories for natural language task management
