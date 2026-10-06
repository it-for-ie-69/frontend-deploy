# Base image of nodejs with alpine linux
FROM node:24-alpine3.21 AS builder

# Install dependencies
RUN apk add --no-cache libc6-compat

# Install pnpm globally
RUN npm install -g pnpm@11

# Set working directory
WORKDIR /app

# Copy everything to the working directory (except those listed in .dockerignore)
COPY . .

# Install dependencies
RUN pnpm install --frozen-lockfile
RUN pnpm run build

# Use nginx to serve the built application
FROM nginx:1.31.6-alpine AS production

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy built assets from builder stage
COPY --from=builder /app/dist .

# Copy nginx configuration template
COPY ./nginx.conf.template /etc/nginx/templates/nginx.conf.template
