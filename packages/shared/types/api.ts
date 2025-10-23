/**
 * Shared type definitions for API communication
 * between frontend and backend
 */

export interface ApiResponse<T = any> {
  data?: T
  message: string
  timestamp: string
}

export interface HealthResponse {
  status: 'ok' | 'error'
  message: string
}

export interface MessageResponse {
  message: string
  timestamp: string
}

export interface ErrorResponse {
  error: string
  message: string
  status_code: number
}

// User-related types
export interface User {
  id: string
  name: string
  email: string
  created_at: string
  updated_at: string
}

export interface CreateUserRequest {
  name: string
  email: string
}

export interface UpdateUserRequest {
  name?: string
  email?: string
}

// Common pagination types
export interface PaginationParams {
  page: number
  size: number
}

export interface PaginatedResponse<T> {
  items: T[]
  total: number
  page: number
  size: number
  pages: number
}

// API endpoint types
export type ApiEndpoints = {
  // Health endpoints
  'GET /': MessageResponse
  'GET /health': HealthResponse

  // Greeting endpoints
  'GET /api/hello/:name': MessageResponse

  // User endpoints (example)
  'GET /api/users': PaginatedResponse<User>
  'POST /api/users': User
  'GET /api/users/:id': User
  'PUT /api/users/:id': User
  'DELETE /api/users/:id': { message: string }
}
