# Data Model: Frontend Todo App with Authentication

## Entities

### User
- **id**: string (unique identifier from authentication system)
- **email**: string (user's email address, used for login)
- **createdAt**: Date (when the user account was created)
- **lastLoginAt**: Date (when the user last logged in)

### Task
- **id**: string (unique identifier for the task)
- **title**: string (the task title, required)
- **description**: string (optional detailed description of the task)
- **completed**: boolean (whether the task is completed or not, default: false)
- **userId**: string (the ID of the user who owns this task)
- **createdAt**: Date (when the task was created)
- **updatedAt**: Date (when the task was last updated)

## State Transitions

### Task State Transitions
- **Incomplete → Complete**: When user marks task as done
- **Complete → Incomplete**: When user unmarks task as done

## Validation Rules

### User Validation
- Email must be a valid email format
- Email must be unique across users

### Task Validation
- Title must be provided (not empty)
- Title must be less than 255 characters
- Description (if provided) must be less than 1000 characters
- userId must match the authenticated user's ID
- createdAt and updatedAt must be valid dates

## Relationships
- A User can have many Tasks (one-to-many relationship)
- Each Task belongs to exactly one User