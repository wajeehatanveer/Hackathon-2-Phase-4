# Quickstart: AI Todo Chatbot Integration

## Environment Setup

### Required Environment Variables

Create a `.env` file in the backend directory with the following variables:

```bash
# Database Configuration (Neon Serverless PostgreSQL)
DATABASE_URL=postgresql://user:password@host.neon.tech/dbname?sslmode=require

# Authentication Configuration (Better Auth)
BETTER_AUTH_SECRET=your_secret_key_min_32_chars
BETTER_AUTH_URL=http://localhost:3000

# Cohere AI Configuration
COHERE_API_KEY=your_cohere_api_key_here
```

### Obtaining API Keys

#### Cohere API Key
1. Visit [https://dashboard.cohere.com](https://dashboard.cohere.com)
2. Sign up or log in to your account
3. Navigate to **API Keys** in the left sidebar
4. Click **Create Key** and copy the key
5. Add to `.env` file as `COHERE_API_KEY`

#### Neon Database URL
1. Visit [https://console.neon.tech](https://console.neon.tech)
2. Create a new project or select existing
3. Copy the connection string from the dashboard
4. Replace placeholders in `.env`

#### Better Auth Secret
Generate a random 32+ character string:
```bash
# Using openssl
openssl rand -base64 32

# Using Python
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

## Installation Steps

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Activate virtual environment (if not already active)
# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate

# Install dependencies (Cohere is already in requirements.txt)
pip install -r requirements.txt

# Verify installation
python -c "from backend.src.models.conversation import Conversation; print('OK')"
```

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies (react-markdown is already included)
npm install

# Verify installation
npm run build
```

### Project Structure Verification

After installation, verify the following files exist:

```
backend/
├── src/
│   ├── models/
│   │   ├── conversation.py    # NEW
│   │   └── message.py         # NEW
│   ├── api/
│   │   └── chat.py            # NEW
│   ├── mcp/
│   │   ├── server.py          # NEW
│   │   └── tools/             # NEW (6 tool files)
│   ├── repositories/
│   │   ├── conversation_repository.py  # NEW
│   │   └── message_repository.py       # NEW
│   └── services/
│       └── cohere_service.py  # NEW

frontend/
├── src/
│   ├── components/
│   │   └── Chat/              # NEW
│   │       ├── ChatButton.tsx
│   │       ├── ChatWindow.tsx
│   │       ├── MessageList.tsx
│   │       ├── MessageInput.tsx
│   │       └── useChat.ts
│   └── services/
│       └── api.ts             # UPDATED (chat functions)
```

---

## Running the Chatbot Locally

### Start Backend Server

```bash
# From backend directory
cd backend

# Activate virtual environment
.venv\Scripts\activate  # Windows
# or
source .venv/bin/activate  # macOS/Linux

# Start FastAPI server with hot reload
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

Backend will be available at: `http://localhost:8000`

API documentation: `http://localhost:8000/docs`

### Start Frontend Server

```bash
# From frontend directory (new terminal)
cd frontend

# Start Next.js development server
npm run dev
```

Frontend will be available at: `http://localhost:3000`

### Verify Connection

1. Open browser to `http://localhost:3000`
2. Log in with your credentials
3. Click the floating chat button (bottom-right corner)
4. Type a test message: "Hello, can you help me manage my tasks?"

---

## Testing Natural Language Queries

### Task Creation

```
User: Add a task to review the project proposal by Friday
Expected: Task created with title "Review the project proposal" and due date set to Friday
```

```
User: Remind me to call the dentist tomorrow at 2pm
Expected: Task created with title "Call the dentist" and due date tomorrow at 2pm
```

```
User: Add groceries to my list
Expected: Task created with title "Groceries", no due date
```

### Task Listing

```
User: Show me my pending tasks
Expected: List of all incomplete tasks
```

```
User: What are my high-priority tasks for this week?
Expected: Filtered list of high-priority tasks due this week
```

```
User: What's due tomorrow?
Expected: List of tasks with due date matching tomorrow
```

### Task Completion

```
User: Mark the dentist appointment as done
Expected: Task with "dentist" in title marked as completed
```

```
User: I finished the groceries task
Expected: Task with "groceries" in title marked as completed
```

### Task Updates

```
User: Change the meeting to 3pm instead
Expected: Task with "meeting" in title updated with new time
```

```
User: Make the report high priority
Expected: Task with "report" in title updated to high priority
```

### Task Deletion

```
User: Delete the old meeting task
Expected: Confirmation request before deletion
```

```
User: Yes, delete it
Expected: Task permanently removed
```

### Identity Queries

```
User: Who am I?
Expected: "You are logged in as [your-email@example.com]"
```

```
User: What email am I using?
Expected: Email address from JWT payload
```

### Multi-Step Queries

```
User: Add a weekly team meeting every Monday and show me my updated task list
Expected: Task created, then list displayed with confirmation of both actions
```

```
User: Create a task to submit taxes and mark it high priority
Expected: Task created with high priority, confirmation message
```

### Edge Cases

```
User: Add blah blah
Expected: "I'd be happy to help! Could you provide more details about the task?"
```

```
User: Delete the meeting (when multiple meetings exist)
Expected: "Which meeting: Team Meeting Mon 10am or Client Meeting Wed 2pm?"
```

```
User: Show my tasks (when no tasks exist)
Expected: "You're all caught up! No tasks yet. Would you like to add one?"
```

---

## Troubleshooting

### Common Issues

#### "COHERE_API_KEY not found"
```bash
# Verify .env file exists and contains the key
cat .env | grep COHERE

# Reload environment variables
# Windows
set /p COHERE_API_KEY=<.env
# macOS/Linux
export $(cat .env | xargs)
```

#### "Database connection failed"
```bash
# Test database connection
psql $DATABASE_URL -c "SELECT 1"

# Verify SSL mode is set
echo $DATABASE_URL | grep sslmode=require
```

#### "JWT validation failed"
```bash
# Verify BETTER_AUTH_SECRET is set and 32+ characters
echo $BETTER_AUTH_SECRET | wc -c

# Regenerate if needed
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

#### "Chat panel not appearing"
1. Check browser console for errors
2. Verify frontend is running on port 3000
3. Clear browser cache and reload
4. Check network tab for failed API requests

### Debug Mode

Enable verbose logging for debugging:

```bash
# Backend
export LOG_LEVEL=DEBUG
uvicorn src.main:app --reload --log-level debug

# Frontend
# Check browser console (F12) for detailed logs
```

### API Testing with curl

```bash
# Test chat endpoint directly
curl -X POST http://localhost:8000/api/550e8400-e29b-41d4-a716-446655440000/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"message": "Add a task to test the API"}'
```

---

## Next Steps

1. **Run Tests**: `pytest backend/tests/` and `npm test` (frontend)
2. **Review Contracts**: See `specs/001-ai-chatbot-integration/contracts/`
3. **Implement MCP Tools**: Follow `tasks.md` for test-first implementation
4. **Deploy**: Configure production environment variables and deploy to hosting platform
