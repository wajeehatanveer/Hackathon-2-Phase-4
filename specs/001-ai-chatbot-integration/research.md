# Research: AI Todo Chatbot Integration

## Cohere Model Selection

**Selected Model**: `command-r-plus`

### Rationale

| Model | Context Window | Tool Calling | Reasoning Quality | Latency | Cost |
|-------|---------------|--------------|-------------------|---------|------|
| command-r | 128K | ✅ | Good | Fast | Lower |
| command-r-plus | 128K | ✅ | **Excellent** | Moderate | Higher |
| command | 4K | ❌ | Basic | Fastest | Lowest |

**Why command-r-plus**:
- Superior reasoning capabilities for complex multi-step queries
- Better natural language understanding for ambiguous task references
- Supports tool-calling patterns via structured output
- 128K context window allows full conversation history inclusion
- Optimized for enterprise RAG and tool-use scenarios

### Alternative Considered: `command-r`
- Faster and cheaper but lower reasoning accuracy
- May struggle with complex date parsing and multi-intent queries
- Suitable for production scaling after hackathon validation

### Model Configuration
```python
COHERE_MODEL = "command-r-plus"
COHERE_TEMPERATURE = 0.7  # Balance creativity and consistency
COHERE_MAX_TOKENS = 1024  # Sufficient for tool calls + responses
```

---

## Tool Call Parsing

### JSON Block Extraction Pattern

Cohere outputs tool calls as JSON blocks within markdown code fences. Parser extracts and validates:

```python
import re
import json

def parse_tool_call(response_text: str) -> dict | None:
    """Extract JSON tool call from Cohere response."""
    # Pattern: ```json { ... } ```
    pattern = r'```json\s*({.*?})\s*```'
    match = re.search(pattern, response_text, re.DOTALL)
    
    if not match:
        # Fallback: try raw JSON without code fences
        pattern = r'{\s*"tool"\s*:\s*".*?"\s*}'
        match = re.search(pattern, response_text, re.DOTALL)
    
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError:
            return None
    return None
```

### Tool Call Schema
```json
{
  "tool": "add_task | delete_task | update_task | mark_complete | list_tasks | get_current_user",
  "params": {
    "title": "string (optional)",
    "description": "string (optional)",
    "priority": "low | medium | high",
    "due_date": "YYYY-MM-DD (optional)",
    "task_id": "uuid (for update/delete/complete)",
    "status": "pending | completed (for list filter)",
    "limit": "integer (for list, default 50)"
  }
}
```

### Error Handling
- **Invalid JSON**: Return error message asking user to rephrase
- **Unknown tool**: Return error message with available commands
- **Missing parameters**: Prompt user for required information
- **Type mismatches**: Coerce types where possible, else request clarification

---

## Multi-Step Chaining

### Loop Until No Tool Call

Complex queries may require sequential tool invocations:

```
User: "Add a weekly team meeting every Monday and show me my updated task list"
```

**Execution Flow**:
1. Parse first tool call: `add_task(title="Weekly team meeting", due_date="2026-02-23")`
2. Execute tool → Get task_id
3. Feed result back to Cohere with original query
4. Parse second tool call: `list_tasks(status="pending")`
5. Execute tool → Get task list
6. Generate final natural language response combining both results

### Implementation Pattern
```python
async def process_chat(user_id: UUID, message: str, conversation_id: UUID | None = None):
    conversation_history = await get_conversation_history(conversation_id)
    max_iterations = 5  # Prevent infinite loops
    iteration = 0
    
    while iteration < max_iterations:
        # Call Cohere with conversation history
        response = await cohere_chat(message, conversation_history, user_id)
        
        # Parse tool call
        tool_call = parse_tool_call(response.text)
        
        if not tool_call:
            # No tool call = final response
            await save_message(conversation_id, "assistant", response.text)
            return response.text
        
        # Execute tool
        tool_result = await execute_mcp_tool(user_id, tool_call)
        
        # Feed result back to Cohere for next iteration
        conversation_history.append({"role": "assistant", "content": f"Tool result: {tool_result}"})
        iteration += 1
    
    return "I've completed your request."
```

### Termination Conditions
1. No tool call detected in response
2. Maximum iterations reached (5)
3. Tool execution error (return error message)
4. User explicitly ends conversation

---

## Conversation Persistence

### Optional conversation_id Parameter

```
POST /api/{user_id}/chat
{
  "message": "Add a task to review the proposal",
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000"  // optional
}
```

### Behavior

| Scenario | Action |
|----------|--------|
| `conversation_id` provided | Append to existing conversation |
| `conversation_id` not provided | Create new conversation, return new ID |
| `conversation_id` invalid (not user's) | Return 404 Not Found |
| `conversation_id` belongs to different user | Return 403 Forbidden |

### Conversation Creation Flow
```python
async def get_or_create_conversation(user_id: UUID, conversation_id: UUID | None = None) -> Conversation:
    if conversation_id:
        conversation = await db.get(Conversation, conversation_id)
        if not conversation or conversation.user_id != user_id:
            raise HTTPException(status_code=404, detail="Conversation not found")
        return conversation
    
    # Create new conversation
    conversation = Conversation(user_id=user_id, title=None)
    db.add(conversation)
    await db.commit()
    await db.refresh(conversation)
    return conversation
```

### Auto-Generated Titles
First user message used to generate conversation title (first 50 chars):
```python
async def update_conversation_title(conversation: Conversation, first_message: str):
    if not conversation.title:
        conversation.title = first_message[:50]
        conversation.updated_at = datetime.utcnow()
        await db.commit()
```

---

## Frontend Chat Panel Layout

### Slide-In Side Panel (Bottom-Right)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│                                         │
│                              ┌──────────┤
│                              │  Chat    │
│                              │  ─────   │
│                              │          │
│                              │ Messages │
│                              │          │
│                              │ ┌──────┐ │
│                              │ │ Input│ │
│                              │ └──────┘ │
│                              └──────────┘
└─────────────────────────────────────────┘
```

### Component Structure
```tsx
// ChatPanel.tsx
<FloatingActionButton onClick={toggleChat} />
{isOpen && (
  <SlideInPanel position="bottom-right" width={400} height={600}>
    <ChatWindow conversationId={conversationId}>
      <MessageList messages={messages} />
      <TypingIndicator visible={isProcessing} />
      <MessageInput onSend={sendMessage} disabled={isProcessing} />
    </ChatWindow>
  </SlideInPanel>
)}
```

### Animation Specs
- **Open**: Slide from bottom-right, 300ms ease-out
- **Close**: Slide to bottom-right, 300ms ease-in
- **Overlay**: Optional dark backdrop on mobile

### Responsive Behavior
| Screen Size | Panel Width | Panel Height |
|-------------|-------------|--------------|
| Desktop (>1024px) | 400px | 600px |
| Tablet (768-1024px) | 350px | 500px |
| Mobile (<768px) | 100% | 100% (fullscreen) |

---

## Message Rendering

### Markdown Support

User and assistant messages support rich text via markdown:

```python
# Backend: Store raw markdown
message.content = "I've added **Buy groceries** to your tasks for _tomorrow at 2pm_!"

# Frontend: Render with markdown library
import ReactMarkdown from 'react-markdown'

<MessageContent>
  <ReactMarkdown>{message.content}</ReactMarkdown>
</MessageContent>
```

### Supported Markdown Elements
| Element | Syntax | Rendered |
|---------|--------|----------|
| Bold | `**text**` | **text** |
| Italic | `_text_` | _text_ |
| Code | `` `code` `` | `code` |
| Lists | `- item` | • item |
| Links | `[text](url)` | [text](url) |
| Blockquote | `> quote` | > quote |

### Task List Rendering
Special formatting for task list responses:

```tsx
// Render task list with interactive elements
{tasks.map(task => (
  <TaskCard
    key={task.id}
    title={task.title}
    dueDate={task.due_date}
    priority={task.priority}
    onComplete={() => markComplete(task.id)}
  />
))}
```

### Message Metadata
```tsx
<Message
  role={message.role}
  timestamp={formatTimestamp(message.created_at)}
>
  <Avatar role={message.role} />
  <Content>{renderMarkdown(message.content)}</Content>
</Message>
```

---

## Typing Indicator

### Animated Dots with Fade Effect

```tsx
// TypingIndicator.tsx
const TypingIndicator = ({ visible }: { visible: boolean }) => {
  if (!visible) return null;
  
  return (
    <div className="typing-indicator">
      <span className="dot dot-1" />
      <span className="dot dot-2" />
      <span className="dot dot-3" />
    </div>
  );
};
```

### CSS Animation
```css
.typing-indicator {
  display: flex;
  gap: 4px;
  padding: 12px 16px;
  background: #f0f0f0;
  border-radius: 20px;
  width: fit-content;
}

.dot {
  width: 8px;
  height: 8px;
  background: #888;
  border-radius: 50%;
  animation: fade 1.4s infinite ease-in-out;
}

.dot-1 { animation-delay: 0s; }
.dot-2 { animation-delay: 0.2s; }
.dot-3 { animation-delay: 0.4s; }

@keyframes fade {
  0%, 80%, 100% { opacity: 0.3; transform: scale(0.8); }
  40% { opacity: 1; transform: scale(1); }
}
```

### Display Logic
```tsx
// Show indicator while:
// 1. Waiting for Cohere API response
// 2. Executing MCP tools
// 3. Saving messages to database

const [isProcessing, setIsProcessing] = useState(false);

const sendMessage = async (text: string) => {
  setIsProcessing(true);
  try {
    await api.chat({ message: text, conversationId });
  } finally {
    setIsProcessing(false);
  }
};
```

### Accessibility
- ARIA live region for screen readers
- `aria-busy="true"` while processing
- Hidden from screen readers when not visible
