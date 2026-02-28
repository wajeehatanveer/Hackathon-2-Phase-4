# Data Model: Backend Specification

## Task Entity

### Fields
- **id** (Integer, Primary Key)
  - Auto-incrementing unique identifier
  - Required for all operations

- **user_id** (String, Indexed)
  - Foreign key linking to user account
  - Required for user isolation
  - Indexed for efficient querying

- **title** (String, Required, Max 200 chars)
  - Task title/description
  - Required field for all tasks
  - Max length validation required

- **description** (Text, Optional, Max 1000 chars)
  - Detailed task description
  - Optional field
  - Max length validation required

- **completed** (Boolean)
  - Task completion status
  - Default: false
  - Required for tracking task status

- **priority** (Enum: low, medium, high)
  - Task priority level
  - Required field
  - Used for sorting and filtering

- **tags** (JSON Array of Strings)
  - List of tags associated with task
  - Optional field
  - Stored as JSON for flexibility

- **due_date** (DateTime, Nullable)
  - Task due date and time
  - Optional field
  - Used for sorting and reminders

- **recurrence** (Enum: none, daily, weekly, monthly)
  - Task recurrence pattern
  - Optional field
  - Default: none
  - Used for creating recurring tasks

- **created_at** (DateTime)
  - Timestamp when task was created
  - Auto-populated
  - Required for sorting and tracking

- **updated_at** (DateTime)
  - Timestamp when task was last updated
  - Auto-populated on updates
  - Required for tracking changes

### Relationships
- **User**: Many-to-one relationship (many tasks belong to one user)
- **Tags**: One-to-many relationship (one task can have many tags)

### Validation Rules
- Title must be 1-200 characters
- Description must be 0-1000 characters if provided
- Priority must be one of: low, medium, high
- Recurrence must be one of: none, daily, weekly, monthly
- Due date must be a valid datetime if provided
- User_id must match authenticated user for all operations

### Indexes
- Primary index on id
- Index on user_id for efficient user-based queries
- Composite index on (user_id, created_at) for efficient chronological queries
- Index on (user_id, completed) for status-based queries

### State Transitions
- New task: completed = false by default
- Task completion: completed = true when PATCH /complete is called
- Task reopening: completed = false when PATCH /complete is called with false
- Task deletion: record is removed from database

## User Entity (Referenced)

### Fields
- **user_id** (String, Primary Key)
  - Unique identifier from Better Auth
  - Required for all operations
  - Used for enforcing user isolation

### Security Constraints
- All task operations must validate that user_id in JWT matches user_id in URL
- Cross-user access attempts must result in 403 Forbidden
- Unauthorized access attempts must result in 401 Unauthorized