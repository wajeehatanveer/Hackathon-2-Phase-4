# Quickstart Guide: Frontend Todo App

## Prerequisites
- Node.js 18+ installed
- npm or yarn package manager
- Access to the backend API (FastAPI server)

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Navigate to the frontend directory**
   ```bash
   cd frontend
   ```

3. **Install dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

4. **Set up environment variables**
   Create a `.env.local` file in the frontend directory with the following:
   ```env
   NEXT_PUBLIC_API_BASE_URL=<your-backend-api-url>
   NEXT_PUBLIC_BETTER_AUTH_URL=<your-auth-url>
   BETTER_AUTH_SECRET=<your-auth-secret>
   ```

5. **Run the development server**
   ```bash
   npm run dev
   # or
   yarn dev
   ```

6. **Open your browser**
   Visit [http://localhost:3000](http://localhost:3000) to see the application

## Key Features

- **Authentication**: Sign up and sign in with email/password using Better Auth
- **Protected Routes**: Access to task management requires authentication
- **Task Management**: Create, read, update, and delete tasks
- **Responsive Design**: Works on mobile, tablet, and desktop devices

## API Integration

The frontend connects to the backend API through a centralized API client that:
- Attaches JWT tokens to all authenticated requests
- Handles 401 Unauthorized responses by redirecting to login
- Provides consistent error handling

## Folder Structure

- `app/` - Next.js App Router pages
- `components/` - Reusable UI components
- `services/` - API and authentication utilities
- `styles/` - Global styles and Tailwind configuration