variable "access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "repository_names" {
  description = "Alumni database frontend/backend ECR repository name"
  type        = map(any)
}

variable "backend_task" {
  description = "Backend task definitions for the backend"
  type        = map(any)
}

variable "frontend_task" {
  description = "Frontend task definitions for the frontend"
  type        = map(any)
}