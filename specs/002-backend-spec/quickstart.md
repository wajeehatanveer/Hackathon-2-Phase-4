# Quickstart Guide: Backend Development

## Prerequisites
- Python 3.11+
- pip package manager
- Access to Neon PostgreSQL database
- Git

## Setup Instructions

### 1. Clone the repository
```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Navigate to backend directory
```bash
cd backend
```

### 3. Create virtual environment
```bash
python -m venv venv
```

### 4. Activate virtual environment
On Windows:
```bash
venv\Scripts\activate
```

On macOS/Linux:
```bash
source venv/bin/activate
```

### 5. Install dependencies
```bash
pip install -r requirements.txt
```

### 6. Create environment file
Create a `.env` file in the backend directory with the following content:
```env
DATABASE_URL=postgresql://neondb_owner:npg_MCJrUQ94Xokm@ep-noisy-sun-a7t1ce48-pooler.ap-southeast-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require
BETTER_AUTH_SECRET=CeopBgG0M864Z43MnZo27oZQBB87xHcN
BETTER_AUTH_URL=http://localhost:3000
```

### 7. Initialize the database
```bash
python init_db.py
```

### 8. Start the development server
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## API Endpoints

Once the server is running, the API will be available at `http://localhost:8000/api`.

### Available Endpoints:
- `GET /{user_id}/tasks` - Get all tasks for a user
- `POST /{user_id}/tasks` - Create a new task
- `GET /{user_id}/tasks/{id}` - Get a specific task
- `PUT /{user_id}/tasks/{id}` - Update a task
- `DELETE /{user_id}/tasks/{id}` - Delete a task
- `PATCH /{user_id}/tasks/{id}/complete` - Update task completion status

## Testing the API

### Authentication
All endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

### Example cURL command:
```bash
curl -X GET \
  http://localhost:8000/api/user123/tasks \
  -H 'Authorization: Bearer <your_jwt_token>' \
  -H 'Content-Type: application/json'
```

## Running Tests

To run the test suite:
```bash
pytest
```

To run tests with coverage:
```bash
pytest --cov=.
```

## Development Workflow

1. Make changes to the code
2. Run tests to ensure functionality: `pytest`
3. Verify API endpoints work as expected
4. Commit changes with descriptive commit messages

## Troubleshooting

### Common Issues:
- **Database Connection Error**: Verify your DATABASE_URL in the .env file
- **JWT Authentication Error**: Ensure the token is valid and properly formatted
- **Port Already in Use**: Change the port in the uvicorn command
- **Dependency Issues**: Run `pip install -r requirements.txt` again

### Useful Commands:
- Format code: `black .`
- Lint code: `flake8 .`
- Check types: `mypy .`