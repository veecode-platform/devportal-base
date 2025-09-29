#!/bin/bash

# DevPortal Base Docker Development Helper Script

#
# we assume a local verdaccio registry is running at http://localhost:4873
# this is used to cache dependencies 
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

getIPAddress() {
    local ip_addr=""
    # uses `ip` if available, otherwise uses `ifconfig`
    if command -v ip >/dev/null 2>&1; then
        ip_addr=$(ip -4 addr show scope global 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -1)
    elif command -v ifconfig >/dev/null 2>&1; then
        ip_addr=$(ifconfig 2>/dev/null | awk '/inet / && $2 != "127.0.0.1" {print $2}' | head -1)
    fi
    # Fallback to 172.17.0.1 if no IP found
    if [ -z "$ip_addr" ]; then
        ip_addr="172.17.0.1"
    fi
    
    echo "$ip_addr"
}

MY_HOST=$(getIPAddress)

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    echo "DevPortal Base Docker Development Helper"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build       Build the Docker image"
    echo "  up          Start the containers"
    echo "  down        Stop and remove containers"
    echo "  shell       Open a shell in the main container"
    echo "  logs        Show container logs"
    echo "  install     Install dependencies inside container"
    echo "  dev         Start development servers inside container"
    echo "  clean       Clean up containers and volumes"
    echo "  restart     Restart the containers"
    echo "  status      Show container status"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build && $0 up && $0 shell"
    echo "  $0 shell"
    echo "  $0 dev"
}

# Function to build the image
build_image() {
    print_status "Building DevPortal Base Docker image..."
    NPM_REG="http://$MY_HOST:4873"
    print_status "Using NPM registry: $NPM_REG (please run a local Verdaccio registry at this address)"
    docker-compose --progress=plain build --build-arg NPM_REGISTRY=$NPM_REG
    print_success "Image built successfully!"
}

# Function to start containers
start_containers() {
    print_status "Starting containers..."
    docker-compose up -d
    print_success "Containers started!"
    print_status "Main container: devportal-base-dev"
    # print_status "Database: devportal-postgres"
    print_status "Use '$0 shell' to access the container shell"
}

# Function to stop containers
stop_containers() {
    print_status "Stopping containers..."
    docker-compose down
    print_success "Containers stopped!"
}

# Function to open shell
open_shell() {
    print_status "Opening shell in devportal-base-dev container..."
    docker-compose exec devportal-base /bin/bash
}

# Function to show logs
show_logs() {
    print_status "Showing container logs..."
    docker-compose logs -f
}

# Function to install dependencies
install_deps() {
    print_status "Installing dependencies inside container..."
    docker-compose exec devportal-base yarn install
    print_success "Dependencies installed!"
}

# Function to start development
start_dev() {
    print_status "Starting development servers inside container..."
    print_warning "This will start both backend and frontend servers"
    print_status "Backend will be available at: http://localhost:7007"
    print_status "Frontend will be available at: http://localhost:3000"
    docker-compose exec devportal-base yarn dev-local
}

# Function to clean up
clean_up() {
    print_warning "This will remove all containers and volumes!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up..."
        docker-compose down -v --remove-orphans
        docker system prune -f
        print_success "Cleanup completed!"
    else
        print_status "Cleanup cancelled."
    fi
}

# Function to restart containers
restart_containers() {
    print_status "Restarting containers..."
    docker-compose restart
    print_success "Containers restarted!"
}

# Function to show status
show_status() {
    print_status "Container status:"
    docker-compose ps
}

# Main script logic
case "${1:-help}" in
    build)
        build_image
        ;;
    up)
        start_containers
        ;;
    down)
        stop_containers
        ;;
    shell)
        open_shell
        ;;
    logs)
        show_logs
        ;;
    install)
        install_deps
        ;;
    dev)
        start_dev
        ;;
    clean)
        clean_up
        ;;
    restart)
        restart_containers
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
