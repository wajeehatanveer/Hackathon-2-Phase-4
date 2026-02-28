# Tasks: Kubernetes Cloud-Native Deployment

**Input**: Design documents from `/specs/001-kubernetes-deployment/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: NOT included - this is infrastructure deployment, not application code. Validation is via kubectl commands and browser tests.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Infrastructure**: `docker/`, `infra/helm/`, `infra/k8s/` at repository root
- **Existing App**: `backend/`, `frontend/` (Phase III code - unchanged)
- **Documentation**: `specs/001-kubernetes-deployment/`

<!--
  ============================================================================
  IMPORTANT: Tasks below are organized by user story from spec.md
  Each story can be implemented, tested, and demonstrated independently
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify prerequisites and prepare environment for Kubernetes deployment

- [ ] T001 [P] Verify Docker Desktop installed and running with `docker --version`
- [ ] T002 [P] Verify Minikube installed with `minikube version`
- [ ] T003 [P] Verify Helm 3.14+ installed with `helm version`
- [ ] T004 [P] Verify kubectl 1.29+ installed with `kubectl version --client`
- [ ] T005 Install kubecti-ai extension (VS Code Marketplace or CLI)
- [ ] T006 Install kagent for autonomous monitoring (`npm install -g kagent` or equivalent)
- [ ] T007 [P] Create `docker/` directory at repository root
- [ ] T008 [P] Create `infra/` directory at repository root
- [ ] T009 [P] Create `infra/helm/` directory structure
- [ ] T010 [P] Create `infra/k8s/` directory for raw manifests (optional)

**Checkpoint**: Prerequisites verified, directory structure created

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T011 Start Minikube cluster: `minikube start --driver=docker --cpus=4 --memory=8192 --addons=ingress,metrics-server`
- [ ] T012 Verify cluster running: `kubectl cluster-info`
- [ ] T013 Create Kubernetes Secret: `kubectl create secret generic ai-todo-secrets --from-literal=BETTER_AUTH_SECRET=<random> --from-literal=COHERE_API_KEY=<key> --from-literal=DATABASE_URL=<connection-string>`
- [ ] T014 Verify Secret created: `kubectl get secret ai-todo-secrets`
- [ ] T015 Create ConfigMap: `kubectl create configmap ai-todo-config --from-literal=NODE_ENV=production --from-literal=PYTHONUNBUFFERED=1 --from-literal=LOG_LEVEL=info`
- [ ] T016 Verify ConfigMap created: `kubectl get configmap ai-todo-config`
- [ ] T017 Configure host alias: Add `127.0.0.1 todo.local` to hosts file (Administrator/root required)
- [ ] T018 Verify host alias: `ping todo.local` should resolve to 127.0.0.1

**Checkpoint**: Foundation ready - cluster running, secrets created, ingress configured. User story implementation can now begin in parallel.

---

## Phase 3: User Story 1 - Deploy Containerized Application (Priority: P1) 🎯 MVP

**Goal**: Deploy complete AI Todo Chatbot to Minikube using Helm charts with all pods reaching Ready state within 30 seconds

**Independent Test**: Execute `helm install` and verify all pods reach Ready state, services created, application accessible via cluster-internal DNS

### Containerization Tasks

- [ ] T019 [P] [US1] Generate frontend Dockerfile using gordon-containerization-agent in `docker/frontend/Dockerfile`
- [ ] T020 [P] [US1] Create frontend `.dockerignore` in `docker/frontend/.dockerignore` (exclude node_modules, .git, .next)
- [ ] T021 [P] [US1] Generate backend Dockerfile using gordon-containerization-agent in `docker/backend/Dockerfile`
- [ ] T022 [P] [US1] Create backend `.dockerignore` in `docker/backend/.dockerignore` (exclude __pycache__, .git, *.pyc)
- [ ] T023 [US1] Build frontend Docker image: `docker build -f docker/frontend/Dockerfile -t ai-todo-frontend:latest .`
- [ ] T024 [US1] Build backend Docker image: `docker build -f docker/backend/Dockerfile -t ai-todo-backend:latest .`
- [ ] T025 [US1] Verify images built: `docker images | grep ai-todo`

### Helm Chart Generation Tasks

- [ ] T026 [P] [US1] Generate umbrella chart structure using helm-chart-architect in `infra/helm/ai-todo/`
- [ ] T027 [P] [US1] Generate frontend subchart using helm-chart-architect in `infra/helm/ai-todo/charts/frontend/`
- [ ] T028 [P] [US1] Generate backend subchart using helm-chart-architect in `infra/helm/ai-todo/charts/backend/`
- [ ] T029 [P] [US1] Generate database subchart (empty reference) in `infra/helm/ai-todo/charts/database/`
- [ ] T030 [US1] Configure values.yaml with replicas=2, resources, probes for frontend
- [ ] T031 [US1] Configure values.yaml with replicas=2, resources, probes, secretRef for backend
- [ ] T032 [US1] Build Helm dependencies: `cd infra/helm/ai-todo && helm dependency build`
- [ ] T033 [US1] Lint Helm chart: `helm lint ./infra/helm/ai-todo`
- [ ] T034 [US1] Test template rendering: `helm template ai-todo ./infra/helm/ai-todo --debug`

### Deployment Tasks

- [ ] T035 [US1] Deploy with Helm: `helm install ai-todo ./infra/helm/ai-todo --namespace=default`
- [ ] T036 [US1] Wait for pods ready: `kubectl wait --for=condition=Ready pods -l component=ai-todo --timeout=300s`
- [ ] T037 [US1] Verify deployment: `helm list` should show ai-todo deployed
- [ ] T038 [US1] Verify pods running: `kubectl get pods -l component=ai-todo` should show all 1/1 Ready
- [ ] T039 [US1] Verify rollout status: `kubectl rollout status deployment/frontend-deployment` and backend

**Checkpoint**: At this point, User Story 1 should be fully functional - application deployed with all pods healthy

---

## Phase 4: User Story 2 - Access via Ingress URL (Priority: P1)

**Goal**: Access application at http://todo.local with full Phase III chatbot functionality (authentication, task CRUD, natural language conversations)

**Independent Test**: Navigate to http://todo.local in browser, login, complete full chatbot conversation ("Add a task to test deployment" → verify task created)

### Ingress Configuration Tasks

- [ ] T040 [P] [US2] Generate Ingress template using kubectl-ai in `infra/helm/ai-todo/charts/frontend/templates/ingress.yaml`
- [ ] T041 [US2] Configure ingress host: `todo.local` with path-based routing (/api → backend, / → frontend)
- [ ] T042 [US2] Upgrade Helm release with ingress: `helm upgrade ai-todo ./infra/helm/ai-todo`
- [ ] T043 [US2] Verify ingress created: `kubectl get ingress ai-todo-ingress`
- [ ] T044 [US2] Describe ingress: `kubectl describe ingress ai-todo-ingress` should show routing rules

### Access Verification Tasks

- [ ] T045 [US2] Start Minikube tunnel in separate terminal: `minikube tunnel`
- [ ] T046 [US2] Verify tunnel running: LoadBalancer Ingress should show 127.0.0.1
- [ ] T047 [US2] Navigate to http://todo.local in browser
- [ ] T048 [US2] Verify frontend loads: Login page should be visible
- [ ] T049 [US2] Login with credentials
- [ ] T050 [US2] Test chatbot: Type "Add a task to verify Kubernetes deployment works"
- [ ] T051 [US2] Verify task created: Task should appear in task list
- [ ] T052 [US2] Test conversation persistence: Type "Show me my tasks" → should list all tasks
- [ ] T053 [US2] Verify database connection: Tasks persist in Neon PostgreSQL

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - deployed application accessible at todo.local with full chatbot functionality

---

## Phase 5: User Story 3 - Self-Healing Demonstration (Priority: P2)

**Goal**: Demonstrate Kubernetes self-healing by deleting a pod and observing automatic recreation within 60 seconds with zero downtime

**Independent Test**: Execute `kubectl delete pod <pod-name>` and verify new pod reaches Ready state within 60 seconds while application remains accessible

### Self-Healing Test Tasks

- [ ] T054 [P] [US3] Identify backend pod to delete: `kubectl get pods -l app=backend`
- [ ] T055 [US3] Record current pods: `kubectl get pods -l component=ai-todo -o wide > before-delete.txt`
- [ ] T056 [US3] Delete backend pod: `kubectl delete pod <backend-pod-name>`
- [ ] T057 [US3] Watch pod recreation: `kubectl get pods -l app=backend -w`
- [ ] T058 [US3] Verify new pod scheduled: New pod should appear in ContainerCreating state
- [ ] T059 [US3] Verify new pod ready: New pod should reach 1/1 Running state within 60 seconds
- [ ] T060 [US3] Monitor application during recovery: Continuously access http://todo.local - should remain accessible
- [ ] T061 [US3] Verify zero downtime: No HTTP errors during pod deletion and recovery
- [ ] T062 [US3] Record recovery time: Measure time from deletion to Ready state
- [ ] T063 [US3] Verify events: `kubectl get events --sort-by='.lastTimestamp'` should show pod scheduled, started

### Frontend Self-Healing Tasks

- [ ] T064 [US3] Delete frontend pod: `kubectl delete pod <frontend-pod-name>`
- [ ] T065 [US3] Watch frontend pod recreation: `kubectl get pods -l app=frontend -w`
- [ ] T066 [US3] Verify frontend recovery within 60 seconds

**Checkpoint**: At this point, User Story 3 should be demonstrated - self-healing with automatic pod recovery

---

## Phase 6: User Story 4 - Scale Replicas and Load Balancing (Priority: P2)

**Goal**: Horizontally scale backend deployment to 4 replicas and observe Kubernetes distributing traffic across all healthy pods with zero downtime

**Independent Test**: Execute `kubectl scale deployment/backend --replicas=4` and verify 4 pods reach Ready state within 30 seconds, all included in service endpoints

### Scaling Tasks

- [ ] T067 [P] [US4] Record current replica count: `kubectl get deployment backend -o wide`
- [ ] T068 [US4] Scale backend deployment: `kubectl scale deployment/backend --replicas=4`
- [ ] T069 [US4] Watch scaling operation: `kubectl get pods -l app=backend -w`
- [ ] T070 [US4] Verify new pods scheduled: 2 new pods should appear in ContainerCreating state
- [ ] T071 [US4] Verify all pods ready: All 4 pods should reach 1/1 Running state within 30 seconds
- [ ] T072 [US4] Verify service endpoints: `kubectl get endpoints backend-service` should list all 4 pod IPs
- [ ] T073 [US4] Monitor application during scaling: Continuously access http://todo.local - all requests should succeed
- [ ] T074 [US4] Verify zero downtime: No HTTP errors during scale-up operation
- [ ] T075 [US4] Record scaling time: Measure time from scale command to all pods ready
- [ ] T076 [US4] Test load balancing: Make multiple rapid requests, observe distribution across pods (via logs)

### Scale Down Tasks

- [ ] T077 [US4] Scale back to 2 replicas: `kubectl scale deployment/backend --replicas=2`
- [ ] T078 [US4] Watch scale-down operation: `kubectl get pods -l app=backend -w`
- [ ] T079 [US4] Verify graceful termination: Pods should terminate cleanly (no errors)
- [ ] T080 [US4] Verify 2 replicas remain: `kubectl get pods -l app=backend` should show 2 running

**Checkpoint**: At this point, User Stories 1-4 should all be demonstrated - deployment, access, self-healing, and scaling

---

## Phase 7: User Story 5 - AI-Powered DevOps (Priority: P3)

**Goal**: Diagnose and resolve cluster issues using kubecti-ai and kagent with natural language queries instead of memorizing kubectl commands

**Independent Test**: Install kubecti-ai, execute natural language queries about pod status/logs/events, verify AI returns accurate actionable responses

### kubecti-ai Setup Tasks

- [ ] T081 [P] [US5] Verify kubecti-ai installed: Check VS Code extension or CLI availability
- [ ] T082 [US5] Configure kubecti-ai with Minikube context
- [ ] T083 [US5] Test basic query: "show me all pods and their status"
- [ ] T084 [US5] Verify AI response: Should return formatted list with pod names, status, restart counts

### kubecti-ai Diagnosis Tasks

- [ ] T085 [US5] Query pod status: "why is pod backend-xyz not ready" (simulate by describing a pod)
- [ ] T086 [US5] Verify AI diagnosis: Should analyze events, logs, probe configuration
- [ ] T087 [US5] Query resource usage: "show me pods with high memory usage"
- [ ] T088 [US5] Verify AI response: Should return pods sorted by memory usage with metrics
- [ ] T089 [US5] Query scaling: "scale deployment backend to 4 replicas"
- [ ] T090 [US5] Verify AI execution: Should execute kubectl scale command and confirm

### kagent Autonomous Monitoring Tasks

- [ ] T091 [P] [US5] Start kagent monitoring: `kagent monitor --cluster=minikube --auto-remediate`
- [ ] T092 [US5] Configure kagent health loops: Set monitoring interval to 30s
- [ ] T093 [US5] Query cluster health: `kagent health analyze`
- [ ] T094 [US5] Verify kagent report: Should return cluster health summary with recommendations
- [ ] T095 [US5] Trigger pod failure: `kubectl delete pod <backend-pod-name>`
- [ ] T096 [US5] Watch kagent detect failure: kagent should alert or auto-remediate
- [ ] T097 [US5] Verify kagent action: Should either restart pod automatically or provide alert with recommended fix
- [ ] T098 [US5] Query optimization suggestions: `kagent optimize resources --namespace=default`
- [ ] T099 [US5] Verify kagent recommendations: Should suggest resource tuning based on observed usage

**Checkpoint**: At this point, all 5 user stories should be demonstrated - deployment, access, self-healing, scaling, and AI DevOps

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final improvements, documentation, and demo preparation

### Documentation Tasks

- [ ] T100 [P] Update README.md with Phase IV deployment section
- [ ] T101 [P] Add Minikube quickstart guide to README (copy from quickstart.md)
- [ ] T102 [P] Create IMPLEMENTATION_LOG.md with agent confirmations and kubectl-ai/kagent outputs
- [ ] T103 [P] Document troubleshooting common issues in README

### Demo Preparation Tasks

- [ ] T104 [P] Capture Minikube dashboard screenshot showing healthy pods
- [ ] T105 [P] Capture browser screenshot of chatbot at todo.local
- [ ] T106 [P] Capture kubectl get pods output showing all replicas
- [ ] T107 [P] Record demo script: 5-7 slide flow for judges (deploy → access → break → heal → scale → AI DevOps)
- [ ] T108 [P] Rehearse demo flow: Time should be under 10 minutes
- [ ] T109 [P] Prepare backup screenshots in case of live demo issues

### Security Hardening Tasks

- [ ] T110 [P] Generate NetworkPolicy using k8s-security-specialist in `infra/k8s/network-policy.yaml`
- [ ] T111 Apply NetworkPolicy: `kubectl apply -f infra/k8s/network-policy.yaml`
- [ ] T112 Verify NetworkPolicy: `kubectl get networkpolicy`
- [ ] T113 Verify all pods run as non-root: `kubectl exec <pod> -- whoami` should not return root
- [ ] T114 Verify resource limits: `kubectl describe pod <pod>` should show limits for all containers

### Observability Tasks

- [ ] T115 [P] Test structured logging: `kubectl logs -f deployment/backend --tail=100`
- [ ] T116 [P] Verify logs include correlation IDs (user_id, conversation_id)
- [ ] T117 [P] Test metrics: `kubectl top pods` should show CPU/memory usage
- [ ] T118 [P] Test events: `kubectl get events --sort-by='.lastTimestamp'` should show recent events
- [ ] T119 [P] Open Minikube dashboard: `minikube dashboard` for visual monitoring

### Final Validation Tasks

- [ ] T120 [P] Run full deployment validation checklist:
  - [ ] All pods running and ready
  - [ ] All services have endpoints
  - [ ] Ingress accessible at todo.local
  - [ ] Chatbot functional (add/list/complete tasks)
  - [ ] Secrets mounted correctly
  - [ ] Health probes passing
  - [ ] Resource limits configured
  - [ ] Non-root containers verified
- [ ] T121 [P] Create demo assets folder with screenshots and logs
- [ ] T122 [P] Write demo narrative: "Watch me deploy, break, heal with AI"
- [ ] T123 [P] Prepare rollback plan: `helm uninstall ai-todo`, `minikube delete --purge`

**Checkpoint**: All phases complete - production-grade Kubernetes deployment ready for hackathon demonstration

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase - P1 (MVP)
- **User Story 2 (Phase 4)**: Depends on User Story 1 completion - P1
- **User Story 3 (Phase 5)**: Depends on User Story 1 completion - P2
- **User Story 4 (Phase 6)**: Depends on User Story 1 completion - P2
- **User Story 5 (Phase 7)**: Depends on User Story 1 completion - P3
- **Polish (Phase 8)**: Depends on all user stories completion

### User Story Dependencies

- **User Story 1 (P1)**: Foundational phase complete - can start after Phase 2
- **User Story 2 (P1)**: User Story 1 complete (deployment must be working)
- **User Story 3 (P2)**: User Story 1 complete (pods must be running to delete them)
- **User Story 4 (P2)**: User Story 1 complete (deployment must be running to scale)
- **User Story 5 (P3)**: User Story 1 complete (cluster must be running for AI queries)

### Within Each User Story

- Containerization tasks (Dockerfiles, images) → Helm chart generation → Deployment → Verification
- Parallel tasks marked [P] can run simultaneously (different files, no dependencies)

### Parallel Opportunities

- **Phase 1 Setup**: T001-T010 all marked [P] - can run in parallel
- **Phase 2 Foundational**: T011-T018 sequential (cluster must start before secrets)
- **Phase 3 US1**: 
  - T019-T022 [P] - Dockerfile generation can run in parallel
  - T026-T029 [P] - Helm chart generation can run in parallel
  - T023-T024 sequential (images must build after Dockerfiles)
- **Phase 4 US2**: T040-T041 [P] - Ingress template generation
- **Phase 5 US3**: T064-T066 can run parallel to T056-T063 (test both frontend and backend)
- **Phase 6 US4**: T067-T080 sequential (scaling is ordered)
- **Phase 7 US5**:
  - T081-T090 sequential (kubecti-ai queries)
  - T091-T099 sequential (kagent monitoring)
- **Phase 8 Polish**: Most tasks marked [P] - can run in parallel

---

## Parallel Example: Phase 3 User Story 1

```bash
# Launch all Dockerfile generation tasks together:
Task: "Generate frontend Dockerfile using gordon-containerization-agent"
Task: "Generate backend Dockerfile using gordon-containerization-agent"
Task: "Create frontend .dockerignore"
Task: "Create backend .dockerignore"

# Launch all Helm chart generation tasks together:
Task: "Generate umbrella chart structure using helm-chart-architect"
Task: "Generate frontend subchart using helm-chart-architect"
Task: "Generate backend subchart using helm-chart-architect"
Task: "Generate database subchart using helm-chart-architect"

# Sequential tasks (must wait for above):
Task: "Build frontend Docker image"
Task: "Build backend Docker image"
Task: "Deploy with Helm"
Task: "Wait for pods ready"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (verify prerequisites)
2. Complete Phase 2: Foundational (start cluster, create secrets)
3. Complete Phase 3: User Story 1 (containerization + Helm deployment)
4. **STOP and VALIDATE**: Test User Story 1 independently
   - `helm list` shows ai-todo deployed
   - `kubectl get pods` shows all pods ready
   - Deploy successful

### Incremental Delivery

1. Complete Setup + Foundational → Cluster ready
2. Add User Story 1 → Deploy application → Test independently → Demo (MVP!)
3. Add User Story 2 → Configure ingress → Test independently → Demo (access at todo.local)
4. Add User Story 3 → Demonstrate self-healing → Test independently → Demo (auto-recovery)
5. Add User Story 4 → Demonstrate scaling → Test independently → Demo (load balancing)
6. Add User Story 5 → Demonstrate AI DevOps → Test independently → Demo (natural language queries)
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers/agents:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (containerization + Helm)
   - Developer B: User Story 2 (ingress configuration) - waits for US1
   - Developer C: Prepare demo assets (Phase 8 tasks)
3. After US1 complete:
   - Developer A: User Story 3 (self-healing tests)
   - Developer B: User Story 4 (scaling tests)
   - Developer C: User Story 5 (AI DevOps setup)
4. Stories complete and integrate independently

---

## Task Summary

| Phase | Description | Task Count | Story |
|-------|-------------|------------|-------|
| Phase 1 | Setup | 10 | N/A |
| Phase 2 | Foundational | 8 | N/A |
| Phase 3 | User Story 1 | 21 | US1 |
| Phase 4 | User Story 2 | 14 | US2 |
| Phase 5 | User Story 3 | 13 | US3 |
| Phase 6 | User Story 4 | 14 | US4 |
| Phase 7 | User Story 5 | 18 | US5 |
| Phase 8 | Polish | 24 | N/A |
| **Total** | **All Phases** | **122** | **5 Stories** |

### Parallel Opportunities

- **Phase 1**: 10/10 tasks parallelizable (100%)
- **Phase 2**: 0/8 tasks parallelizable (0% - sequential cluster setup)
- **Phase 3**: 10/21 tasks parallelizable (48%)
- **Phase 4**: 2/14 tasks parallelizable (14%)
- **Phase 5**: 2/13 tasks parallelizable (15%)
- **Phase 6**: 0/14 tasks parallelizable (0% - sequential scaling)
- **Phase 7**: 2/18 tasks parallelizable (11%)
- **Phase 8**: 20/24 tasks parallelizable (83%)

### Suggested MVP Scope

**Minimum Viable Product**: Phases 1-3 only (39 tasks)
- Setup verified
- Cluster running with secrets
- Application deployed via Helm
- All pods healthy

**Demo-Ready**: Phases 1-7 (98 tasks)
- All user stories demonstrated
- Self-healing, scaling, AI DevOps working
- Ready for hackathon presentation

**Production Polish**: All phases (122 tasks)
- Full documentation
- Security hardening
- Observability configured
- Demo assets prepared

---

## Notes

- [P] tasks = different files, no dependencies, can run in parallel
- [US1/US2/US3/US4/US5] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each phase or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- All kubectl commands are copy-paste safe with --driver=docker
- Rollback safety: `helm uninstall ai-todo`, `minikube delete --purge`
