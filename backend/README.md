# РЕХА SUPPLY Backend API

Backend API for РЕХА SUPPLY service management system.

## Features

- User authentication (JWT-based)
- Service request management (CRUD operations)
- Technician management
- Announcements system
- MongoDB database

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (local or cloud instance)
- npm or yarn

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file in the backend directory:
```bash
cp .env.example .env
```

3. Update the `.env` file with your MongoDB connection string and other configuration:
```
MONGODB_URI=mongodb://localhost:27017/rehamed
PORT=5000
JWT_SECRET=your-secret-key-change-in-production
```

## Running the Server

### Development mode (with auto-reload):
```bash
npm run dev
```

### Production mode:
```bash
npm start
```

The server will start on `http://localhost:5000` (or the port specified in `.env`).

## API Endpoints

### Authentication

- `POST /api/auth/login` - Login user
  - Body: `{ "username": "string", "password": "string" }`
  - Returns: `{ "token": "string", "user": {...} }`

- `POST /api/auth/register` - Register new user
  - Body: `{ "username": "string", "password": "string", "name": "string", "email": "string?" }`
  - Returns: `{ "token": "string", "user": {...} }`

- `GET /api/auth/me` - Get current user (requires token)
  - Headers: `Authorization: Bearer <token>`

### Service Requests

- `GET /api/service-requests` - Get all service requests (user's own or all if admin)
- `GET /api/service-requests/:id` - Get service request by ID
- `POST /api/service-requests` - Create new service request
- `PUT /api/service-requests/:id` - Update service request
- `DELETE /api/service-requests/:id` - Delete service request
- `GET /api/service-requests/status/:status` - Get requests by status

### Technicians

- `GET /api/technicians` - Get all technicians
- `GET /api/technicians/:id` - Get technician by ID
- `POST /api/technicians` - Create technician (admin only)
- `PUT /api/technicians/:id` - Update technician (admin only)
- `DELETE /api/technicians/:id` - Delete technician (admin only)

### Announcements

- `GET /api/announcements` - Get all announcements
- `GET /api/announcements/recent?limit=5` - Get recent announcements
- `GET /api/announcements/:id` - Get announcement by ID
- `POST /api/announcements` - Create announcement (admin only)
- `PUT /api/announcements/:id` - Update announcement (admin only)
- `DELETE /api/announcements/:id` - Delete announcement (admin only)

## Authentication

Most endpoints require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your-token>
```

## Database Models

### User
- username (unique)
- password (hashed)
- name
- email
- role (user, admin, technician)

### ServiceRequest
- userId
- type (emergency, maintenance, cleaning, equipment, other)
- title
- description
- location
- status (pending, accepted, inProgress, completed, cancelled)
- assignedTo (technician ID)
- notes
- images
- isUrgent
- scheduledDate
- scheduledTime

### Technician
- name
- phone
- specialization
- email
- isActive

### Announcement
- title
- content
- author
- isImportant
- createdAt

## Example Usage

### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}'
```

### Create Service Request
```bash
curl -X POST http://localhost:5000/api/service-requests \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "type": "maintenance",
    "title": "Засвар хийлгэх",
    "description": "Дэлгэрэнгүй тайлбар",
    "location": "Байршил",
    "isUrgent": false
  }'
```

## Notes

- Change the JWT_SECRET in production
- Use a secure MongoDB connection string in production
- Consider adding rate limiting and additional security measures for production
