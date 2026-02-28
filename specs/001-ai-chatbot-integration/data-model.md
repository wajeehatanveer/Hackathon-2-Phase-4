# Data Model: AI Chatbot Integration

## Entity Definitions

### Conversation

Represents a persistent chat session belonging to a user.

```python
from datetime import datetime
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field, Relationship
from typing import TYPE_CHECKING

class Conversation(SQLModel, table=True):
    __tablename__ = "conversations"

    id: UUID | None = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True, nullable=False)
    title: str | None = Field(default=None, max_length=200)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)

    # Relationships
    if TYPE_CHECKING:
        messages: list["Message"] = Relationship(back_populates="conversation")
        user: "User" = Relationship(back_populates="conversations")
```

**Fields**:
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | Primary Key, Auto-generated | Unique conversation identifier |
| user_id | UUID | Foreign Key → users.id, Indexed, Not Null | Owner of the conversation |
| title | str | Max 200 chars, Nullable | Auto-generated from first message |
| created_at | datetime | Not Null, Default now | Conversation creation timestamp |
| updated_at | datetime | Not Null, Default now | Last message timestamp |

---

### Message

Represents an individual exchange within a conversation.

```python
from datetime import datetime
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field, Relationship
from typing import TYPE_CHECKING

class Message(SQLModel, table=True):
    __tablename__ = "messages"

    id: UUID | None = Field(default_factory=uuid4, primary_key=True)
    conversation_id: UUID = Field(foreign_key="conversations.id", index=True, nullable=False)
    role: str = Field(..., max_length=20, nullable=False)  # "user" | "assistant" | "system"
    content: str = Field(..., max_length=10000, nullable=False)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)

    # Relationships
    if TYPE_CHECKING:
        conversation: Conversation | None = Relationship(back_populates="messages")
```

**Fields**:
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | Primary Key, Auto-generated | Unique message identifier |
| conversation_id | UUID | Foreign Key → conversations.id, Indexed, Not Null | Parent conversation |
| role | str | Max 20 chars, Not Null | Message sender: "user", "assistant", or "system" |
| content | str | Max 10000 chars, Not Null | Message text (markdown supported) |
| created_at | datetime | Not Null, Default now | Message timestamp |

---

## Relationships

```
┌─────────────┐       ┌──────────────┐       ┌─────────────┐
│    User     │       │ Conversation │       │   Message   │
├─────────────┤       ├──────────────┤       ├─────────────┤
│ id (PK)     │◄──────│ user_id (FK) │       │ id (PK)     │
│ email       │  1:N  │ id (PK)      │◄──────│ conv_id(FK) │
│ ...         │       │ title        │  1:N  │ role        │
└─────────────┘       │ created_at   │       │ content     │
                      │ updated_at   │       │ created_at  │
                      └──────────────┘       └─────────────┘
```

**Cardinality**:
- User → Conversations: One-to-Many (user can have multiple conversations)
- Conversation → Messages: One-to-Many (conversation contains multiple messages)
- Message → Conversation: Many-to-One (message belongs to one conversation)

---

## Indexes

### Required Indexes

```sql
-- Conversation indexes
CREATE INDEX idx_conversations_user_id ON conversations(user_id);
CREATE INDEX idx_conversations_created_at ON conversations(created_at DESC);
CREATE INDEX idx_conversations_user_created ON conversations(user_id, created_at DESC);

-- Message indexes
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at ASC);
CREATE INDEX idx_messages_conv_created ON messages(conversation_id, created_at ASC);
```

### Index Justification

| Index | Purpose | Query Pattern |
|-------|---------|---------------|
| `idx_conversations_user_id` | List user's conversations | `WHERE user_id = ?` |
| `idx_conversations_created_at` | Sort by recency | `ORDER BY created_at DESC` |
| `idx_conversations_user_created` | Combined filter + sort | `WHERE user_id = ? ORDER BY created_at DESC` |
| `idx_messages_conversation_id` | Get conversation history | `WHERE conversation_id = ?` |
| `idx_messages_created_at` | Chronological ordering | `ORDER BY created_at ASC` |
| `idx_messages_conv_created` | Combined filter + sort | `WHERE conversation_id = ? ORDER BY created_at ASC` |

---

## Async CRUD Operations

### Conversation Repository

```python
from sqlmodel import SQLModel, select, func
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from datetime import datetime

class ConversationRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, user_id: UUID) -> Conversation:
        """Create a new conversation for a user."""
        conversation = Conversation(user_id=user_id)
        self.session.add(conversation)
        await self.session.commit()
        await self.session.refresh(conversation)
        return conversation

    async def get_by_id(self, conversation_id: UUID, user_id: UUID) -> Conversation | None:
        """Get conversation by ID, scoped to user."""
        statement = select(Conversation).where(
            Conversation.id == conversation_id,
            Conversation.user_id == user_id
        )
        result = await self.session.execute(statement)
        return result.scalar_one_or_none()

    async def list_by_user(self, user_id: UUID, limit: int = 50, offset: int = 0) -> list[Conversation]:
        """List user's conversations, ordered by recency."""
        statement = (
            select(Conversation)
            .where(Conversation.user_id == user_id)
            .order_by(Conversation.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        result = await self.session.execute(statement)
        return list(result.scalars().all())

    async def update_title(self, conversation_id: UUID, title: str) -> Conversation | None:
        """Update conversation title."""
        statement = select(Conversation).where(Conversation.id == conversation_id)
        result = await self.session.execute(statement)
        conversation = result.scalar_one_or_none()
        
        if conversation:
            conversation.title = title
            conversation.updated_at = datetime.utcnow()
            await self.session.commit()
            await self.session.refresh(conversation)
        return conversation

    async def delete(self, conversation_id: UUID, user_id: UUID) -> bool:
        """Delete conversation and cascade delete messages."""
        statement = select(Conversation).where(
            Conversation.id == conversation_id,
            Conversation.user_id == user_id
        )
        result = await self.session.execute(statement)
        conversation = result.scalar_one_or_none()
        
        if conversation:
            await self.session.delete(conversation)
            await self.session.commit()
            return True
        return False
```

### Message Repository

```python
class MessageRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def create(self, conversation_id: UUID, role: str, content: str) -> Message:
        """Create a new message in a conversation."""
        message = Message(conversation_id=conversation_id, role=role, content=content)
        self.session.add(message)
        await self.session.commit()
        await self.session.refresh(message)
        
        # Update conversation's updated_at
        await self._update_conversation_timestamp(conversation_id)
        return message

    async def _update_conversation_timestamp(self, conversation_id: UUID):
        """Update parent conversation's updated_at timestamp."""
        statement = select(Conversation).where(Conversation.id == conversation_id)
        result = await self.session.execute(statement)
        conversation = result.scalar_one_or_none()
        
        if conversation:
            conversation.updated_at = datetime.utcnow()
            await self.session.commit()

    async def list_by_conversation(
        self, 
        conversation_id: UUID, 
        limit: int = 100, 
        offset: int = 0
    ) -> list[Message]:
        """Get messages for a conversation, ordered chronologically."""
        statement = (
            select(Message)
            .where(Message.conversation_id == conversation_id)
            .order_by(Message.created_at.asc())
            .limit(limit)
            .offset(offset)
        )
        result = await self.session.execute(statement)
        return list(result.scalars().all())

    async def get_last_message(self, conversation_id: UUID) -> Message | None:
        """Get the most recent message in a conversation."""
        statement = (
            select(Message)
            .where(Message.conversation_id == conversation_id)
            .order_by(Message.created_at.desc())
            .limit(1)
        )
        result = await self.session.execute(statement)
        return result.scalar_one_or_none()

    async def count_by_conversation(self, conversation_id: UUID) -> int:
        """Count messages in a conversation."""
        statement = select(func.count()).select_from(Message).where(
            Message.conversation_id == conversation_id
        )
        result = await self.session.execute(statement)
        return result.scalar() or 0
```

### Usage Example

```python
# In chat API endpoint
async def chat_endpoint(
    user_id: UUID,
    request: ChatRequest,
    db: AsyncSession = Depends(get_db)
):
    conv_repo = ConversationRepository(db)
    msg_repo = MessageRepository(db)
    
    # Get or create conversation
    if request.conversation_id:
        conversation = await conv_repo.get_by_id(request.conversation_id, user_id)
        if not conversation:
            raise HTTPException(status_code=404, detail="Conversation not found")
    else:
        conversation = await conv_repo.create(user_id)
    
    # Save user message
    await msg_repo.create(conversation.id, "user", request.message)
    
    # Process with Cohere and save assistant response
    response = await process_with_cohere(user_id, request.message, conversation.id)
    await msg_repo.create(conversation.id, "assistant", response)
    
    return ChatResponse(
        conversation_id=conversation.id,
        message=response
    )
```

---

## Migration Script

```python
"""Add conversation and message tables

Revision ID: 001-ai-chatbot
Revises: phase-ii-complete
Create Date: 2026-02-17

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    # Create conversations table
    op.create_table(
        'conversations',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('title', sa.String(length=200), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE')
    )
    
    # Create messages table
    op.create_table(
        'messages',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('conversation_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('role', sa.String(length=20), nullable=False),
        sa.Column('content', sa.String(length=10000), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['conversation_id'], ['conversations.id'], ondelete='CASCADE')
    )
    
    # Create indexes
    op.create_index('idx_conversations_user_id', 'conversations', ['user_id'])
    op.create_index('idx_conversations_created_at', 'conversations', ['created_at', 'desc'])
    op.create_index('idx_conversations_user_created', 'conversations', ['user_id', 'created_at', 'desc'])
    
    op.create_index('idx_messages_conversation_id', 'messages', ['conversation_id'])
    op.create_index('idx_messages_created_at', 'messages', ['created_at', 'asc'])
    op.create_index('idx_messages_conv_created', 'messages', ['conversation_id', 'created_at', 'asc'])

def downgrade():
    op.drop_index('idx_messages_conv_created', table_name='messages')
    op.drop_index('idx_messages_created_at', table_name='messages')
    op.drop_index('idx_messages_conversation_id', table_name='messages')
    
    op.drop_index('idx_conversations_user_created', table_name='conversations')
    op.drop_index('idx_conversations_created_at', table_name='conversations')
    op.drop_index('idx_conversations_user_id', table_name='conversations')
    
    op.drop_table('messages')
    op.drop_table('conversations')
```
