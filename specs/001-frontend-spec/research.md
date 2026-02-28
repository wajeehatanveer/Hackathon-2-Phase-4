# Research: Frontend Todo App with Authentication

## Decision: Testing Framework
**Rationale**: For a Next.js application with TypeScript, the most common and well-supported testing frameworks are Jest with React Testing Library. This combination provides excellent React component testing capabilities and integrates well with Next.js.
**Alternatives considered**: 
- Cypress (end-to-end testing, but not ideal for unit/component testing)
- Vitest (faster but newer, less community support for Next.js)

## Decision: Better Auth Integration
**Rationale**: Better Auth is specified in the requirements and provides a complete authentication solution that handles JWT issuance and session management. It integrates well with Next.js applications.
**Alternatives considered**:
- NextAuth.js (popular alternative but not specified in requirements)
- Auth0 or other third-party solutions (would require additional costs)

## Decision: API Client Implementation
**Rationale**: Using a centralized API client (like a custom fetch wrapper or axios) allows for consistent JWT attachment to requests and centralized error handling, meeting the requirements for automatic JWT attachment and 401 handling.
**Alternatives considered**:
- Direct fetch calls (would lead to code duplication)
- SWR or React Query (data fetching libraries, but don't handle authentication directly)

## Decision: Protected Route Implementation
**Rationale**: Next.js App Router allows for custom middleware and client-side protection using React context or hooks. A combination of server-side and client-side checks will ensure proper route protection.
**Alternatives considered**:
- Next.js middleware (server-side, but doesn't handle client-side navigation)
- Client-side only (less secure)