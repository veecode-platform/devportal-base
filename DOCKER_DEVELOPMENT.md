# Docker Development Setup

This guide helps you set up and use Docker for developing the DevPortal Base project.

## Quick Start

### 1. Build and Start Containers

```bash
# Build the Docker image
docker-compose build

# Start containers in detached mode
docker-compose up -d

# Open a shell in the container
docker-compose exec devportal-base /bin/bash
```

### 2. Using the Helper Script (Recommended)

Make the script executable first:

```bash
chmod +x docker-dev.sh
```

Then use the helper commands:

```bash
# Build and start everything
./docker-dev.sh build
./docker-dev.sh up

# Open a shell in the container
./docker-dev.sh shell

# Start development servers
./docker-dev.sh dev
```

## Available Services

### Main Application Container (`devportal-base`)

- **Purpose**: Development environment for the DevPortal Base
- **Ports**: 
  - `3000`: Frontend development server
  - `7007`: Backend API server
- **Volumes**: 
  - Project source code mounted at `/app`
  - Node modules volume for performance
  - Yarn cache for faster installs

### PostgreSQL Database (`postgres`)

- **Purpose**: Local database for development
- **Port**: `5432`
- **Credentials**:
  - Database: `backstage`
  - User: `backstage` 
  - Password: `backstage`

## Development Workflow

### 1. Initial Setup

```bash
# Build the image
docker-compose build

# Start containers
docker-compose up -d

# Install dependencies
docker-compose exec devportal-base yarn install
```

### 2. Development

```bash
# Open shell for development
docker-compose exec devportal-base /bin/bash

# Inside the container, start development servers
yarn dev-local

# Or start individual services
yarn start-backend  # Backend only
yarn dev            # Both frontend and backend
```

### 3. Common Commands

#### Container Management

```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# Restart containers
docker-compose restart

# View logs
docker-compose logs -f

# Check container status
docker-compose ps
```

#### Development Commands (Inside Container)

```bash
# Install dependencies
yarn install

# Start development with local config
yarn dev-local

# Build the project
yarn build

# Run tests
yarn test

# Lint code
yarn lint

# Type checking
yarn tsc
```

## Helper Script Commands

The `docker-dev.sh` script provides convenient commands:

```bash
./docker-dev.sh build       # Build the Docker image
./docker-dev.sh up          # Start containers
./docker-dev.sh down        # Stop containers
./docker-dev.sh shell       # Open shell in container
./docker-dev.sh logs        # Show container logs
./docker-dev.sh install     # Install dependencies
./docker-dev.sh dev         # Start development servers
./docker-dev.sh clean       # Clean up containers and volumes
./docker-dev.sh restart     # Restart containers
./docker-dev.sh status      # Show container status
./docker-dev.sh help        # Show help
```

## Configuration

### Environment Variables

The container uses these environment variables:

- `NODE_ENV=development`
- `NODE_OPTIONS=--no-node-snapshot`

### Volumes

- **Source Code**: `.:/app` - Your local code is mounted for live editing
- **Node Modules**: `node_modules:/app/node_modules` - Persistent for performance
- **Yarn Cache**: `yarn_cache:/usr/local/share/.cache/yarn` - Faster installs

### Ports

- **3000**: Frontend development server
- **7007**: Backend API server
- **5432**: PostgreSQL database

## Troubleshooting

### Container Won't Start

```bash
# Check container logs
docker-compose logs devportal-base

# Rebuild the image
docker-compose build --no-cache
```

### Permission Issues

```bash
# Fix file permissions (run on host)
sudo chown -R $USER:$USER .
```

### Database Connection Issues

```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Connect to database
docker-compose exec postgres psql -U backstage -d backstage
```

### Clean Start

```bash
# Stop everything and clean up
docker-compose down -v --remove-orphans
docker system prune -f

# Rebuild and start fresh
docker-compose build --no-cache
docker-compose up -d
```

## Tips

1. **Live Reload**: Your local code changes are immediately reflected in the container
2. **Performance**: Node modules are stored in a Docker volume for better performance
3. **Database**: PostgreSQL data persists between container restarts
4. **Debugging**: Use `docker-compose logs -f` to see real-time logs
5. **Shell Access**: Always available via `docker-compose exec devportal-base /bin/bash`

## Integration with Existing Workflow

This Docker setup is designed to work alongside your existing development workflow:

- All your existing `yarn` commands work inside the container
- Configuration files (`app-config.*.yaml`) are mounted and accessible
- The Makefile commands can be run inside the container
- Dynamic plugins development is fully supported
