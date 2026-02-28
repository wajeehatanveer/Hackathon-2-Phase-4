# Tasks: AI Todo Chatbot Integration

**Input**: Design documents from `/specs/001-ai-chatbot-integration/`
**Prerequisites**: plan.md, spec.md, data-model.md, quickstart.md, contracts/

**Tests**: Tests are OPTIONAL - included here for production-ready implementation with contract and integration tests.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Web app**: `backend/src/`, `frontend/src/`
- Paths follow the structure defined in plan.md

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Verify backend directory structure exists per plan.md
- [X] T002 Verify frontend directory structure exists per plan.md
- [X] T003 [P] Add Cohere Python client to backend dependencies (requirements.txt or pyproject.toml)
- [X] T004 [P] Add markdown rendering library to frontend dependencies (react-markdown or similar)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 [P] Create Conversation model in `backend/src/models/conversation.py` per data-model.md
- [X] T006 [P] Create Message model in `backend/src/models/message.py` per data-model.md
- [X] T007 [P] Create database migration for conversations and messages tables in `backend/alembic/versions/`
- [X] T008 Run database migration to create tables
- [X] T009 [P] Create indexes on conversations.user_id, messages.conversation_id, messages.created_at
- [X] T010 [P] Implement ConversationRepository in `backend/src/repositories/conversation_repository.py`
- [X] T011 [P] Implement MessageRepository in `backend/src/repositories/message_repository.py`
- [X] T012 Setup async database session management for new repositories
- [X] T013 Configure COHERE_API_KEY environment variable loading in `backend/src/core/config.py`
- [X] T014 [P] Create CohereService wrapper in `backend/src/services/cohere_service.py`
- [X] T015 Setup MCP server structure in `backend/src/mcp/server.py`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Natural Language Task Creation (Priority: P1) 🎯 MVP

**Goal**: Enable users to create tasks via natural language chat commands

**Independent Test**: User can type "Add task to call dentist tomorrow at 2pm" and verify task appears in database with correct title and due date

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T016 [P] [US1] Contract test for add_task tool in `backend/tests/contract/test_add_task.py`
- [ ] T017 [P] [US1] Integration test for task creation via chat in `backend/tests/integration/test_chat_task_creation.py`

### Implementation for User Story 1

- [X] T018 [P] [US1] Implement add_task MCP tool in `backend/src/mcp/tools/add_task.py`
- [X] T019 [P] [US1] Implement get_current_user MCP tool in `backend/src/mcp/tools/get_current_user.py`
- [X] T020 [US1] Implement Cohere prompt engineering for task creation intent in `backend/src/services/cohere_service.py`
- [X] T021 [US1] Add JSON tool call parsing logic to CohereService
- [X] T022 [US1] Implement tool execution dispatcher in `backend/src/mcp/server.py`
- [X] T023 [US1] Create POST /api/{user_id}/chat endpoint in `backend/src/api/chat.py`
- [X] T024 [US1] Add JWT authentication middleware to chat endpoint
- [X] T025 [US1] Implement conversation creation/loading logic in chat endpoint
- [X] T026 [US1] Save user message to database in chat endpoint
- [X] T027 [US1] Save assistant response to database
- [X] T028 [US1] Add error handling for Cohere API failures
- [X] T029 [US1] Add logging with user_id and conversation_id for traceability
- [X] T030 [P] [US1] Create ChatWindow component in `frontend/src/components/Chat/ChatWindow.tsx`
- [X] T031 [P] [US1] Create MessageList component in `frontend/src/components/Chat/MessageList.tsx`
- [X] T032 [P] [US1] Create MessageInput component in `frontend/src/components/Chat/MessageInput.tsx`
- [X] T033 [US1] Add floating chatbot button to layout in `frontend/src/components/Layout/`
- [X] T034 [US1] Implement chat panel slide-in animation
- [X] T035 [US1] Add message bubble styling (user right/indigo, assistant left/slate)
- [X] T036 [US1] Implement send message API call from frontend to chat endpoint
- [X] T037 [US1] Add loading state and typing indicator during API call
- [X] T038 [US1] Display assistant response in chat UI
- [X] T039 [US1] Auto-scroll to bottom on new message
- [X] T040 [US1] Add markdown rendering for assistant responses

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently - users can create tasks via natural language chat

---

## Phase 4: User Story 2 - Conversational Task Listing and Filtering (Priority: P1)

**Goal**: Enable users to retrieve filtered task lists via natural language queries

**Independent Test**: User can type "Show my pending tasks" or "What are my high-priority tasks?" and receive accurate filtered list

### Tests for User Story 2

- [ ] T041 [P] [US2] Contract test for list_tasks tool in `backend/tests/contract/test_list_tasks.py`
- [ ] T042 [P] [US2] Integration test for filtered task listing in `backend/tests/integration/test_chat_task_listing.py`

### Implementation for User Story 2

- [X] T043 [P] [US2] Implement list_tasks MCP tool in `backend/src/mcp/tools/list_tasks.py`
- [X] T044 [US2] Add list_tasks tool schema to CohereService system prompt
- [X] T045 [US2] Implement filter parsing (status, priority, due_date) in list_tasks tool
- [X] T046 [US2] Add natural language date parsing ("tomorrow", "next week", "this Friday")
- [X] T047 [US2] Format task list responses with markdown (bold titles, bullet points)
- [X] T048 [US2] Handle empty task list with encouraging message
- [X] T049 [US2] Add pagination support for large task lists (limit 50 by default)
- [X] T050 [US2] Update frontend MessageList to render task list markdown properly
- [X] T051 [US2] Add conversation history loading in frontend
- [X] T052 [US2] Implement conversation persistence across page refreshes

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - users can create and list tasks conversationally

---

## Phase 5: User Story 3 - Task Completion and Updates via Chat (Priority: P2)

**Goal**: Enable users to mark tasks complete and update task details through conversation

**Independent Test**: User can type "Mark the dentist task as complete" or "Change the meeting to 3pm" and verify changes in database

### Tests for User Story 3

- [ ] T053 [P] [US3] Contract test for mark_complete tool in `backend/tests/contract/test_mark_complete.py`
- [ ] T054 [P] [US3] Contract test for update_task tool in `backend/tests/contract/test_update_task.py`
- [ ] T055 [P] [US3] Integration test for task completion flow in `backend/tests/integration/test_chat_task_completion.py`

### Implementation for User Story 3

- [X] T056 [P] [US3] Implement mark_complete MCP tool in `backend/src/mcp/tools/mark_complete.py`
- [X] T057 [P] [US3] Implement update_task MCP tool in `backend/src/mcp/tools/update_task.py`
- [X] T058 [US3] Add mark_complete and update_task schemas to CohereService system prompt
- [ ] T059 [US3] Implement task title-based lookup (find task by partial title match)
- [ ] T060 [US3] Handle ambiguous task references (multiple matches → ask for clarification)
- [X] T061 [US3] Add confirmation message for task completion
- [X] T062 [US3] Implement field-specific updates (title, description, priority, due_date)
- [X] T063 [US3] Add validation for update parameters
- [X] T064 [US3] Return updated task details in confirmation message
- [X] T065 [US3] Update frontend to handle task update confirmations in chat

**Checkpoint**: At this point, User Stories 1, 2, AND 3 should all work independently - users can create, list, complete, and update tasks conversationally

---

## Phase 6: User Story 4 - User Identity and Context Queries (Priority: P2)

**Goal**: Enable users to query their identity and account context

**Independent Test**: User can type "Who am I?" and receive their email address from JWT

### Tests for User Story 4

- [ ] T066 [P] [US4] Contract test for get_current_user tool in `backend/tests/contract/test_get_current_user.py`
- [ ] T067 [P] [US4] Integration test for identity query in `backend/tests/integration/test_chat_identity.py`

### Implementation for User Story 4

- [X] T068 [P] [US4] Enhance get_current_user tool to return email from JWT payload
- [X] T069 [US4] Add identity query handling to CohereService (direct response, no tool call needed)
- [X] T070 [US4] Implement "Who am I?" intent detection
- [X] T071 [US4] Format identity response ("You are logged in as user@example.com")
- [X] T072 [US4] Add support for other account context queries ("What's my email?")

**Checkpoint**: User Stories 1-4 functional - users can manage tasks and query identity

---

## Phase 7: User Story 5 - Task Deletion with Confirmation (Priority: P3)

**Goal**: Enable users to delete tasks with explicit confirmation for destructive actions

**Independent Test**: User can type "Delete the old meeting task" and chatbot requests confirmation before deletion

### Tests for User Story 5

- [ ] T073 [P] [US5] Contract test for delete_task tool in `backend/tests/contract/test_delete_task.py`
- [ ] T074 [P] [US5] Integration test for deletion confirmation flow in `backend/tests/integration/test_chat_task_deletion.py`

### Implementation for User Story 5

- [X] T075 [P] [US5] Implement delete_task MCP tool in `backend/src/mcp/tools/delete_task.py`
- [X] T076 [US5] Add delete_task schema to CohereService system prompt
- [ ] T077 [US5] Implement confirmation state management (track pending deletion)
- [ ] T078 [US5] Add confirmation prompt ("Are you sure you want to delete...?")
- [ ] T079 [US5] Handle confirmation responses ("Yes, delete it" / "Actually, keep it")
- [ ] T080 [US5] Implement cancellation logic
- [ ] T081 [US5] Add deletion confirmation message
- [X] T082 [US5] Handle non-existent task deletion gracefully
- [ ] T083 [US5] Update frontend to handle multi-turn confirmation flows

**Checkpoint**: All 5 core user stories functional - full conversational task management complete

---

## Phase 8: User Story 6 - Multi-Step Conversational Flows (Priority: P3)

**Goal**: Enable users to chain multiple operations in a single conversation

**Independent Test**: User can type "Add task to submit report Friday and show my tasks" and both operations execute correctly

### Tests for User Story 6

- [ ] T084 [P] [US6] Integration test for multi-step flow in `backend/tests/integration/test_chat_multi_step.py`

### Implementation for User Story 6

- [X] T085 [US6] Implement multi-turn conversation loop in CohereService
- [X] T086 [US6] Add tool call chaining (execute multiple tools in sequence)
- [X] T087 [US6] Feed tool results back to Cohere for final natural language response
- [X] T088 [US6] Handle compound intents ("Add X and show my tasks")
- [X] T089 [US6] Implement conversation context retention across turns
- [X] T090 [US6] Add maximum loop iteration limit (prevent infinite loops)
- [X] T091 [US6] Format multi-step confirmations ("I've added X and here are your tasks...")
- [X] T092 [US6] Test complex queries: "Add weekly meeting and list pending tasks"

**Checkpoint**: All 6 user stories complete - chatbot handles simple and compound conversational flows

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories, UI polish, and production readiness

### Error Handling & Edge Cases

- [X] T093 Add graceful error handling for malformed Cohere JSON responses
- [X] T094 Add retry logic for transient Cohere API failures
- [X] T095 Implement helpful error messages for users ("I'm having trouble connecting...")
- [ ] T096 Handle gibberish/vague input with clarification requests
- [ ] T097 Add timeout handling for long-running Cohere calls
- [ ] T098 Implement rate limiting for chat endpoint

### UI Polish & Delight

- [X] T099 Add glassmorphic styling to assistant message bubbles
- [X] T100 [P] Add subtle pulse animation to chatbot button on hover
- [X] T101 [P] Add animated dots typing indicator
- [X] T102 [P] Add message fade-in animation on appearance
- [X] T103 [P] Add send button ripple effect on click
- [X] T104 Implement dark/light theme awareness for chat panel
- [ ] T105 Add mobile touch optimization (swipe to close panel)
- [X] T106 Add ARIA labels for accessibility
- [X] T107 Implement keyboard shortcuts (Enter to send, Escape to close)

### Performance & Scalability

- [X] T108 Add database query optimization (verify indexes used)
- [X] T109 Implement conversation history pagination (load last 50 messages)
- [ ] T110 Add caching for frequently accessed data
- [ ] T111 Profile chat endpoint performance (target p95 <500ms)
- [ ] T112 Load test with 1000+ concurrent users

### Documentation & Demo Prep

- [X] T113 [P] Update README.md with Cohere setup instructions
- [X] T114 [P] Add natural language query examples to README
- [ ] T115 [P] Create "AI Magic Highlights" section for hackathon judges
- [X] T116 [P] Document all 6 MCP tools in API documentation
- [ ] T117 Create IMPLEMENTATION_LOG.md with architectural decisions
- [ ] T118 Prepare demo script with example queries
- [ ] T119 Record demo video showcasing natural language handling

### Final Validation

- [ ] T120 Run end-to-end test for all user stories
- [ ] T121 Validate JWT security (invalid token → 401)
- [ ] T122 Validate user isolation (cross-user access denied)
- [ ] T123 Test server restart (conversation history persists)
- [ ] T124 Test concurrent chat sessions
- [ ] T125 UI perfection audit (animations, theme switching, mobile)
- [ ] T126 Intelligence audit (diverse natural language queries)
- [ ] T127 Fix all critical bugs before hackathon submission

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies - can start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 - **BLOCKS all user stories**
- **Phase 3 (US1 - Task Creation)**: Depends on Phase 2 - **MVP READY after completion**
- **Phase 4 (US2 - Task Listing)**: Depends on Phase 2 - Can run parallel to US3+
- **Phase 5 (US3 - Task Completion/Updates)**: Depends on Phase 2 - Can run parallel to US2+
- **Phase 6 (US4 - Identity Queries)**: Depends on Phase 2 - Can run parallel to US3+
- **Phase 7 (US5 - Task Deletion)**: Depends on Phase 2 - Can run parallel to US4+
- **Phase 8 (US6 - Multi-Step Flows)**: Depends on Phases 3-7 (all tools must exist)
- **Phase 9 (Polish)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: Depends on Foundational phase - **INDEPENDENTLY TESTABLE** - MVP scope
- **User Story 2 (P1)**: Depends on Foundational phase - **INDEPENDENTLY TESTABLE**
- **User Story 3 (P2)**: Depends on Foundational phase - **INDEPENDENTLY TESTABLE**
- **User Story 4 (P2)**: Depends on Foundational phase - **INDEPENDENTLY TESTABLE**
- **User Story 5 (P3)**: Depends on Foundational phase - **INDEPENDENTLY TESTABLE**
- **User Story 6 (P3)**: Depends on all previous user stories (requires all tools) - **INDEPENDENTLY TESTABLE**

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- **Phase 1**: All setup tasks marked [P] can run in parallel
- **Phase 2**: All foundational tasks marked [P] can run in parallel
- **After Phase 2**: All user stories (Phases 3-7) can start in parallel (if team capacity allows)
- **Within User Stories**:
  - All tests marked [P] can run in parallel
  - All models within a story marked [P] can run in parallel
  - Frontend components marked [P] can run in parallel with backend
- **Phase 9**: All polish tasks marked [P] can run in parallel

---

## Parallel Execution Examples

### Example 1: Parallel Model Creation (Phase 2)

```bash
# Launch all at once:
Task: "T005 [P] Create Conversation model in backend/src/models/conversation.py"
Task: "T006 [P] Create Message model in backend/src/models/message.py"
Task: "T009 [P] Create database indexes"
Task: "T010 [P] Create ConversationRepository"
Task: "T011 [P] Create MessageRepository"
```

### Example 2: Parallel User Story Implementation (After Phase 2)

```bash
# Team A works on US1 (Task Creation):
Task: "T018 [P] [US1] Implement add_task MCP tool"
Task: "T030 [P] [US1] Create ChatWindow component"

# Team B works on US2 (Task Listing) in parallel:
Task: "T043 [P] [US2] Implement list_tasks MCP tool"

# Team C works on US4 (Identity) in parallel:
Task: "T068 [P] [US4] Enhance get_current_user tool"
```

### Example 3: Parallel Frontend Components (Phase 3)

```bash
# Launch all frontend component tasks together:
Task: "T030 [P] [US1] Create ChatWindow.tsx"
Task: "T031 [P] [US1] Create MessageList.tsx"
Task: "T032 [P] [US1] Create MessageInput.tsx"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Natural Language Task Creation)
4. **STOP and VALIDATE**: Test User Story 1 independently
   - User types: "Add task to call dentist tomorrow at 2pm"
   - Verify: Task created with correct title and due date
   - Verify: Chatbot confirms creation
   - Verify: Task appears in task list
5. Deploy/demo MVP if ready for hackathon checkpoint

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → **Deploy/Demo (MVP!)**
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Add User Story 4 → Test independently → Deploy/Demo
6. Add User Story 5 → Test independently → Deploy/Demo
7. Add User Story 6 → Test independently → Deploy/Demo
8. Complete Phase 9: Polish → Final hackathon submission

**Each story adds value without breaking previous stories**

### Parallel Team Strategy

With multiple developers/agents:

1. Team completes Setup + Foundational together
2. Once Foundational is done, split into parallel tracks:
   - **Developer A (Backend Tools)**: US1 add_task, US2 list_tasks, US3 mark_complete/update_task
   - **Developer B (Backend AI)**: CohereService, chat endpoint, multi-step flows
   - **Developer C (Frontend)**: Chat components, styling, animations
3. Stories complete and integrate independently
4. Reconvene for Phase 9: Polish (all hands)

---

## Task Summary

| Phase | Description | Task Count |
|-------|-------------|------------|
| Phase 1 | Setup | 4 tasks |
| Phase 2 | Foundational | 11 tasks |
| Phase 3 | User Story 1 (Task Creation) | 25 tasks |
| Phase 4 | User Story 2 (Task Listing) | 11 tasks |
| Phase 5 | User Story 3 (Task Completion/Updates) | 13 tasks |
| Phase 6 | User Story 4 (Identity Queries) | 5 tasks |
| Phase 7 | User Story 5 (Task Deletion) | 9 tasks |
| Phase 8 | User Story 6 (Multi-Step Flows) | 8 tasks |
| Phase 9 | Polish & Cross-Cutting | 35 tasks |
| **Total** | **All phases** | **121 tasks** |

### MVP Scope (Minimum for Hackathon Demo)

- Phase 1: Setup (4 tasks)
- Phase 2: Foundational (11 tasks)
- Phase 3: User Story 1 (25 tasks)
- **MVP Total**: 40 tasks

### Full Production-Ready Implementation

- All 9 phases: **121 tasks**

---

## Notes

- [P] tasks = different files, no dependencies, can run in parallel
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (if tests included)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- **Critical Success Factor**: Complete Phase 2 (Foundational) before starting ANY user story
- **MVP Strategy**: Stop after User Story 1 for minimum viable demo
- **Hackathon Timeline**: 24-36 hours with parallel agent execution
