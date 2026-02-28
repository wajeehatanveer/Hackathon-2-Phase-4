# API Contracts: Frontend Todo App

## Authentication Endpoints

### POST /api/auth/signup
**Description**: Create a new user account
**Request**:
- Headers: `Content-Type: application/json`
- Body:
  ```json
  {
    "email": "string (required)",
    "password": "string (required, min 8 chars)"
  }
  ```
**Response**:
- 200: User created successfully, returns JWT token
- 400: Invalid input (email format, password strength, etc.)
- 409: User already exists

### POST /api/auth/login
**Description**: Authenticate user and return JWT token
**Request**:
- Headers: `Content-Type: application/json`
- Body:
  ```json
  {
    "email": "string (required)",
    "password": "string (required)"
  }
  ```
**Response**:
- 200: Authentication successful, returns JWT token
- 400: Invalid input
- 401: Invalid credentials

### POST /api/auth/logout
**Description**: Logout user and invalidate session
**Request**:
- Headers: `Authorization: Bearer <token>`
**Response**:
- 200: Logout successful
- 401: Invalid or expired token

## Task Management Endpoints

### GET /api/tasks
**Description**: Get all tasks for the authenticated user
**Request**:
- Headers: `Authorization: Bearer <token>`
**Response**:
- 200: Returns array of tasks
  ```json
  [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "completed": "boolean",
      "userId": "string",
      "createdAt": "string (ISO date)",
      "updatedAt": "string (ISO date)"
    }
  ]
  ```
- 401: Invalid or expired token

### POST /api/tasks
**Description**: Create a new task
**Request**:
- Headers: `Authorization: Bearer <token>`, `Content-Type: application/json`
- Body:
  ```json
  {
    "title": "string (required)",
    "description": "string (optional)",
    "completed": "boolean (optional, default: false)"
  }
  ```
**Response**:
- 201: Task created successfully, returns the created task
- 400: Invalid input
- 401: Invalid or expired token

### GET /api/tasks/{id}
**Description**: Get a specific task by ID
**Request**:
- Headers: `Authorization: Bearer <token>`
**Response**:
- 200: Returns the task
- 401: Invalid or expired token
- 404: Task not found

### PUT /api/tasks/{id}
**Description**: Update an existing task
**Request**:
- Headers: `Authorization: Bearer <token>`, `Content-Type: application/json`
- Body:
  ```json
  {
    "title": "string (optional)",
    "description": "string (optional)",
    "completed": "boolean (optional)"
  }
  ```
**Response**:
- 200: Task updated successfully, returns the updated task
- 400: Invalid input
- 401: Invalid or expired token
- 404: Task not found

### PATCH /api/tasks/{id}
**Description**: Partially update a task (e.g., toggle completion status)
**Request**:
- Headers: `Authorization: Bearer <token>`, `Content-Type: application/json`
- Body:
  ```json
  {
    "completed": "boolean"
  }
  ```
**Response**:
- 200: Task updated successfully, returns the updated task
- 400: Invalid input
- 401: Invalid or expired token
- 404: Task not found

### DELETE /api/tasks/{id}
**Description**: Delete a task
**Request**:
- Headers: `Authorization: Bearer <token>`
**Response**:
- 204: Task deleted successfully
- 401: Invalid or expired token
- 404: Task not found