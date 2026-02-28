# API Contract: Task Management Backend

## Overview
This document specifies the API contracts for the task management backend. All endpoints require JWT authentication and enforce user isolation.

## Authentication
All endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

## Base URL
```
http://localhost:8000/api
```

## Common Headers
- `Content-Type: application/json`
- `Authorization: Bearer <jwt_token>`

## Common Error Responses
- `400 Bad Request`: Invalid input data
- `401 Unauthorized`: Missing or invalid JWT token
- `403 Forbidden`: Attempt to access another user's data
- `404 Not Found`: Resource does not exist
- `500 Internal Server Error`: Server error

## Endpoints

### GET /{user_id}/tasks
Retrieve all tasks for a specific user with optional filtering, searching, and sorting.

#### Path Parameters
- `user_id` (string, required): The ID of the user whose tasks to retrieve

#### Query Parameters
- `search` (string, optional): Search term to match against title and description
- `status` (string, optional): Filter by completion status ('completed' or 'pending')
- `priority` (string, optional): Filter by priority ('low', 'medium', 'high')
- `tag` (string, optional): Filter by tag
- `sort` (string, optional): Sort order ('created_at', 'title', 'priority', 'due_date')

#### Request Headers
- `Authorization: Bearer <jwt_token>`

#### Response
- `200 OK`: Successful response with array of tasks
```json
[
  {
    "id": 1,
    "user_id": "user123",
    "title": "Sample Task",
    "description": "Task description",
    "completed": false,
    "priority": "medium",
    "tags": ["work", "important"],
    "due_date": "2023-12-31T10:00:00Z",
    "recurrence": "none",
    "created_at": "2023-01-01T10:00:00Z",
    "updated_at": "2023-01-01T10:00:00Z"
  }
]
```

### POST /{user_id}/tasks
Create a new task for the specified user.

#### Path Parameters
- `user_id` (string, required): The ID of the user creating the task

#### Request Headers
- `Authorization: Bearer <jwt_token>`

#### Request Body
```json
{
  "title": "New Task",
  "description": "Task description",
  "priority": "medium",
  "tags": ["tag1", "tag2"],
  "due_date": "2023-12-31T10:00:00Z",
  "recurrence": "none"
}
```

#### Response
- `201 Created`: Task successfully created
```json
{
  "id": 1,
  "user_id": "user123",
  "title": "New Task",
  "description": "Task description",
  "completed": false,
  "priority": "medium",
  "tags": ["tag1", "tag2"],
  "due_date": "2023-12-31T10:00:00Z",
  "recurrence": "none",
  "created_at": "2023-01-01T10:00:00Z",
  "updated_at": "2023-01-01T10:00:00Z"
}
```

### GET /{user_id}/tasks/{id}
Retrieve a specific task by ID for the specified user.

#### Path Parameters
- `user_id` (string, required): The ID of the user
- `id` (integer, required): The ID of the task

#### Request Headers
- `Authorization: Bearer <jwt_token>`

#### Response
- `200 OK`: Task successfully retrieved
```json
{
  "id": 1,
  "user_id": "user123",
  "title": "Sample Task",
  "description": "Task description",
  "completed": false,
  "priority": "medium",
  "tags": ["work", "important"],
  "due_date": "2023-12-31T10:00:00Z",
  "recurrence": "none",
  "created_at": "2023-01-01T10:00:00Z",
  "updated_at": "2023-01-01T10:00:00Z"
}
```

### PUT /{user_id}/tasks/{id}
Update an existing task for the specified user.

#### Path Parameters
- `user_id` (string, required): The ID of the user
- `id` (integer, required): The ID of the task

#### Request Headers
- `Authorization: Bearer <jwt_token>`

#### Request Body
```json
{
  "title": "Updated Task",
  "description": "Updated description",
  "priority": "high",
  "tags": ["updated", "important"],
  "due_date": "2023-12-31T10:00:00Z",
  "recurrence": "weekly",
  "completed": false
}
```

#### Response
- `200 OK`: Task successfully updated
```json
{
  "id": 1,
  "user_id": "user123",
  "title": "Updated Task",
  "description": "Updated description",
  "completed": false,
  "priority": "high",
  "tags": ["updated", "important"],
  "due_date": "2023-12-31T10:00:00Z",
  "recurrence": "weekly",
  "created_at": "2023-01-01T10:00:00Z",
  "updated_at": "2023-01-02T10:00:00Z"
}
```

### DELETE /{user_id}/tasks/{id}
Delete a specific task for the specified user.

#### Path Parameters
- `user_id` (string, required): The ID of the user
- `id` (integer, required): The ID of the task

#### Request Headers
- `Authorization: Bearer <jwt_token>`

#### Response
- `204 No Content`: Task successfully deleted

### PATCH /{user_id}/tasks/{id}/complete
Mark a task as complete or incomplete for the specified user.

#### Path Parameters
- `user_id` (string, required): The ID of the user
- `id` (integer, required): The ID of the task

#### Request Headers
- `Authorization: Bearer <jwt_token>`

#### Query Parameters
- `completed` (boolean, required): Whether the task is completed

#### Response
- `200 OK`: Task completion status successfully updated
```json
{
  "id": 1,
  "user_id": "user123",
  "title": "Sample Task",
  "description": "Task description",
  "completed": true,
  "priority": "medium",
  "tags": ["work", "important"],
  "due_date": "2023-12-31T10:00:00Z",
  "recurrence": "none",
  "created_at": "2023-01-01T10:00:00Z",
  "updated_at": "2023-01-02T10:00:00Z"
}
```

## Security Requirements
1. All endpoints require valid JWT authentication
2. User ID in URL must match user ID in JWT token
3. Users cannot access other users' tasks
4. All inputs must be validated
5. Proper error responses must be returned for all failure cases