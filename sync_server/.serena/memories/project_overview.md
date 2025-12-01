# Sync Server - Project Overview

## Purpose
The sync_server is a backend synchronization server for a Sewing Planner application. It provides:
- User authentication (signup/login) with session management
- WebSocket connections for real-time event synchronization
- PostgreSQL database for persistent storage of users and projects
- SQLite database for session storage
- Event-based data synchronization architecture

## Architecture
This is a Rust-based web server built with Actix-web framework, designed to handle:
- RESTful API endpoints for user operations
- WebSocket connections for bi-directional real-time communication
- Database operations using Diesel ORM (async)
- Session management with SQLite storage
- Password hashing with Argon2

## Key Features
- User registration and authentication
- Session-based authentication with cookies
- WebSocket support for real-time event streaming
- Project management for users
- CORS support (permissive on Windows, default on Linux)
- Connection pooling for database access (max 10 connections)
- Automatic expired session cleanup (every 100 seconds)

## Server Configuration
- **Host**: localhost
- **Port**: 8080
- **Workers**: 1 (single-threaded mode)
- **Allocator**: MiMalloc (high-performance allocator)

## Environment Variables
The server requires the following environment variables (loaded from `.env` file):
- `COOKIE_SECRET_KEY`: Base64-encoded secret key for session cookies
- `DATABASE_URL`: PostgreSQL connection string (default: "postgres://postgres:postgres@localhost:7777")
- `DATABASE_URL` (for sessions): SQLite database path (default: "./sessions.db")

## Tech Stack Summary
- **Language**: Rust (edition 2024)
- **Web Framework**: Actix-web 4.x
- **Database**: PostgreSQL (async) + SQLite (sync)
- **ORM**: Diesel 2.2.0 with diesel-async 0.7.0
- **Password Hashing**: Argon2
- **Session Store**: Custom SQLite-based implementation
- **WebSocket**: actix-ws 0.3.0
- **Serialization**: serde + serde_json