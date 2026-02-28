---

description: "Task list template for feature implementation"
---

# Tasks: Frontend Todo App with Authentication

**Input**: Design documents from `/specs/001-frontend-todo-auth/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create project structure per implementation plan in frontend/
- [X] T002 Initialize Next.js project with TypeScript, Tailwind CSS, and Better Auth dependencies
- [X] T003 [P] Configure linting and formatting tools (ESLint, Prettier)
- [X] T004 Create environment configuration files (.env.example)
- [X] T005 Setup Next.js configuration (next.config.js)
- [X] T006 Setup Tailwind CSS configuration (tailwind.config.js)
- [X] T007 Setup TypeScript configuration (tsconfig.json)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T008 [P] Create centralized API client in frontend/src/services/api-client.ts
- [X] T009 [P] Implement JWT attachment logic in API client
- [X] T010 [P] Implement 401 Unauthorized response handling in API client
- [X] T011 Create authentication utilities in frontend/src/services/auth.ts
- [X] T012 Create TypeScript type definitions in frontend/src/services/types.ts
- [X] T013 Set up basic layout structure in frontend/src/app/layout.tsx
- [X] T014 Implement protected route handling using React context
- [X] T015 Create reusable UI components (Button, Input, Loading) in frontend/src/components/

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - User Authentication (Priority: P1) 🎯 MVP

**Goal**: Enable new users to sign up for an account and access the application

**Independent Test**: A new user can navigate to the signup page, enter their email and password, and successfully create an account. The user is then logged in and redirected to the task list page.

### Implementation for User Story 1

- [X] T016 [P] [US1] Create AuthForm component in frontend/src/components/AuthForm.tsx
- [X] T017 [US1] Implement signup page UI in frontend/src/app/signup/page.tsx
- [X] T018 [US1] Add form validation and error handling to signup page
- [X] T019 [US1] Implement signup API call using API client
- [X] T020 [US1] Handle successful signup and redirect to task list page
- [X] T021 [US1] Add loading states during signup process

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - User Login (Priority: P1)

**Goal**: Enable existing users to sign in to their account and access their tasks

**Independent Test**: An existing user can navigate to the login page, enter their credentials, and successfully log in to access their tasks.

### Implementation for User Story 2

- [X] T022 [P] [US2] Update AuthForm component to support login in frontend/src/components/AuthForm.tsx
- [X] T023 [US2] Implement login page UI in frontend/src/app/login/page.tsx
- [X] T024 [US2] Add form validation and error handling to login page
- [X] T025 [US2] Implement login API call using API client
- [X] T026 [US2] Handle successful login and redirect to task list page
- [X] T027 [US2] Implement session management after login
- [X] T028 [US2] Add loading states during login process

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 4 - Session Management (Priority: P2)

**Goal**: Ensure users remain logged in during their sessions and can be properly logged out

**Independent Test**: A user remains logged in across page refreshes and is properly logged out when they choose to log out or when their session expires.

### Implementation for User Story 4

- [X] T029 [P] [US4] Implement session persistence across page refreshes
- [X] T030 [US4] Create logout functionality in frontend/src/services/auth.ts
- [X] T031 [US4] Implement logout API call and session invalidation
- [X] T032 [US4] Add Navbar component with logout option in frontend/src/components/Navbar.tsx
- [X] T033 [US4] Handle expired session redirects to login page
- [ ] T034 [US4] Implement JWT token refresh mechanism if needed

**Checkpoint**: At this point, User Stories 1, 2 AND 4 should all work independently

---

## Phase 6: User Story 5 - Protected Routes (Priority: P3)

**Goal**: Ensure unauthenticated users are redirected to the login page when trying to access protected routes

**Independent Test**: Unauthenticated users cannot access protected routes and are redirected to the login page.

### Implementation for User Story 5

- [X] T035 [P] [US5] Implement protected route wrapper component
- [X] T036 [US5] Protect /tasks route by implementing authentication check
- [X] T037 [US5] Protect /tasks/new route by implementing authentication check
- [X] T038 [US5] Protect /tasks/[id] route by implementing authentication check
- [X] T039 [US5] Redirect unauthenticated users to login page
- [ ] T040 [US5] Test route protection with both authenticated and unauthenticated users

**Checkpoint**: At this point, all authentication-related user stories should work independently

---

## Phase 7: User Story 3 - Task Management (Priority: P2)

**Goal**: Enable authenticated users to create, view, update, and delete their tasks

**Independent Test**: An authenticated user can perform all CRUD operations on their tasks through the UI.

### Implementation for User Story 3

- [X] T041 [P] [US3] Create TaskCard component in frontend/src/components/TaskCard.tsx
- [X] T042 [P] [US3] Create TaskForm component in frontend/src/components/TaskForm.tsx
- [X] T043 [US3] Implement task list page in frontend/src/app/tasks/page.tsx
- [X] T044 [US3] Implement create task page in frontend/src/app/tasks/new/page.tsx
- [X] T045 [US3] Implement task detail/edit page in frontend/src/app/tasks/[id]/page.tsx
- [X] T046 [US3] Implement GET tasks API call to fetch user's tasks
- [X] T047 [US3] Implement POST task API call to create new tasks
- [X] T048 [US3] Implement GET single task API call to fetch specific task
- [X] T049 [US3] Implement PUT task API call to update existing tasks
- [X] T050 [US3] Implement PATCH task API call to toggle completion status
- [X] T051 [US3] Implement DELETE task API call to delete tasks
- [X] T052 [US3] Add confirmation flow for delete task operation
- [X] T053 [US3] Implement empty state UI when no tasks exist
- [X] T054 [US3] Add loading states for all task operations

**Checkpoint**: All user stories should now be independently functional

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T055 [P] Add responsive behavior for mobile, tablet, and desktop
- [ ] T056 [P] Improve spacing, typography, and visual consistency
- [ ] T057 [P] Ensure accessibility rules are met (ARIA attributes, keyboard navigation)
- [ ] T058 [P] Add disabled states for buttons during API requests
- [ ] T059 [P] Handle API errors gracefully with user-friendly messages
- [ ] T060 [P] Handle edge case: expired JWT token during session
- [ ] T061 [P] Handle edge case: network errors during API calls
- [ ] T062 [P] Handle edge case: empty task lists
- [ ] T063 [P] Prevent duplicate submissions during API calls
- [ ] T064 [P] Validate all user inputs according to data model rules
- [ ] T065 [P] Documentation updates in frontend/README.md
- [ ] T066 Code cleanup and refactoring
- [ ] T067 Performance optimization across all stories
- [ ] T068 [P] Additional unit tests in frontend/tests/unit/
- [ ] T069 Security hardening
- [ ] T070 Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2/US4 but should be independently testable
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) and requires authentication (US1/US2) - May integrate with other stories but should be independently testable

### Within Each User Story

- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all components for User Story 1 together:
Task: "Create AuthForm component in frontend/src/components/AuthForm.tsx"
Task: "Implement signup page UI in frontend/src/app/signup/page.tsx"
Task: "Add form validation and error handling to signup page"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 4 → Test independently → Deploy/Demo
5. Add User Story 5 → Test independently → Deploy/Demo
6. Add User Story 3 → Test independently → Deploy/Demo
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 4
   - Developer D: User Story 5
3. After authentication stories are complete:
   - Developer E: User Story 3
4. All developers: Polish & Cross-Cutting Concerns

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence