#!/bin/bash
set -e

# DevPortal Base Local Image Build Script
# Replicates the GitHub Actions workflow for local builds
#
# Usage:
#   ./scripts/build-local-image.sh [OPTIONS]
#
# Options:
#   --quick, -q      Skip lint and tests for faster builds
#   --skip-build, -s Skip all artifact building (just run docker build)
#   --no-cache       Disable Docker layer caching
#   --help, -h       Show help message

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="veecode/devportal-base"
DOCKERFILE_PATH="packages/backend/Dockerfile"
DYNAMIC_PLUGINS_DOCKER_DIR="dynamic-plugins-docker"

# Flags
QUICK_MODE=false
SKIP_BUILD=false
NO_CACHE=""

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

print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

show_help() {
    echo "DevPortal Base Local Image Build Script"
    echo ""
    echo "Builds the veecode/devportal-base Docker image locally,"
    echo "replicating the GitHub Actions CI workflow."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --quick, -q      Skip lint and tests for faster builds"
    echo "  --skip-build, -s Skip all artifact building (just run docker build)"
    echo "                   Assumes you've already built artifacts previously"
    echo "  --no-cache       Disable Docker layer caching"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Full build (mirrors CI)"
    echo "  $0 --quick            # Skip lint/test for faster iteration"
    echo "  $0 --skip-build       # Only rebuild Docker image"
    echo "  $0 --quick --no-cache # Quick build without Docker cache"
}

get_version() {
    node -p "require('./package.json').version"
}

check_prerequisites() {
    print_step "Checking prerequisites"

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    print_status "Docker found: $(docker --version)"

    if ! command -v yarn &> /dev/null; then
        print_error "Yarn is not installed or not in PATH"
        exit 1
    fi
    print_status "Yarn found: $(yarn --version)"

    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed or not in PATH"
        exit 1
    fi
    print_status "Node.js found: $(node --version)"

    if [ ! -f "package.json" ]; then
        print_error "package.json not found. Run this script from the repository root."
        exit 1
    fi

    print_success "All prerequisites met"
}

build_monorepo() {
    print_step "Building monorepo artifacts"

    print_status "Installing dependencies..."
    yarn install --immutable

    print_status "Running TypeScript compilation..."
    yarn tsc

    if [ "$QUICK_MODE" = false ]; then
        print_status "Running lint checks..."
        yarn lint:check

        print_status "Running tests..."
        yarn test
    else
        print_warning "Skipping lint and tests (quick mode)"
    fi

    print_status "Building all packages..."
    yarn build:all

    print_success "Monorepo build complete"
}

build_dynamic_plugins() {
    print_step "Building dynamic plugins"

    print_status "Creating $DYNAMIC_PLUGINS_DOCKER_DIR directory..."
    mkdir -p "$DYNAMIC_PLUGINS_DOCKER_DIR"

    print_status "Installing dynamic plugins dependencies..."
    (cd dynamic-plugins && yarn install)

    print_status "Building dynamic plugins..."
    (cd dynamic-plugins && yarn build)

    print_status "Exporting dynamic plugins..."
    (cd dynamic-plugins && yarn export-dynamic)

    print_status "Copying dynamic plugins to $DYNAMIC_PLUGINS_DOCKER_DIR..."
    (cd dynamic-plugins && yarn copy-dynamic-plugins "$(pwd)/../$DYNAMIC_PLUGINS_DOCKER_DIR")

    print_success "Dynamic plugins build complete"
}

build_docker_image() {
    local version
    version=$(get_version)

    print_step "Building Docker image"

    print_status "Version: $version"
    print_status "Image name: $IMAGE_NAME"
    print_status "Tags: $version, latest"

    local docker_args=(
        build
        -f "$DOCKERFILE_PATH"
        --tag "$IMAGE_NAME:$version"
        --tag "$IMAGE_NAME:latest"
        --progress plain
    )

    if [ -n "$NO_CACHE" ]; then
        print_warning "Docker cache disabled"
        docker_args+=(--no-cache)
    fi

    docker_args+=(.)

    print_status "Running: docker ${docker_args[*]}"
    docker "${docker_args[@]}"

    print_success "Docker image built successfully"
    echo ""
    print_status "Image tags created:"
    echo "  - $IMAGE_NAME:$version"
    echo "  - $IMAGE_NAME:latest"
}

verify_artifacts() {
    print_step "Verifying build artifacts exist"

    local missing=false

    if [ ! -f "packages/backend/dist/bundle.tar.gz" ]; then
        print_error "Missing: packages/backend/dist/bundle.tar.gz"
        missing=true
    fi

    if [ ! -f "packages/backend/dist/skeleton.tar.gz" ]; then
        print_error "Missing: packages/backend/dist/skeleton.tar.gz"
        missing=true
    fi

    if [ ! -d "$DYNAMIC_PLUGINS_DOCKER_DIR" ] || [ -z "$(ls -A $DYNAMIC_PLUGINS_DOCKER_DIR 2>/dev/null)" ]; then
        print_error "Missing or empty: $DYNAMIC_PLUGINS_DOCKER_DIR/"
        missing=true
    fi

    if [ "$missing" = true ]; then
        print_error "Required artifacts are missing. Run without --skip-build first."
        exit 1
    fi

    print_success "All required artifacts found"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick|-q)
            QUICK_MODE=true
            shift
            ;;
        --skip-build|-s)
            SKIP_BUILD=true
            shift
            ;;
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

# Main execution
echo ""
echo -e "${GREEN}DevPortal Base Local Image Build${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""

if [ "$QUICK_MODE" = true ]; then
    print_warning "Quick mode enabled - skipping lint and tests"
fi

if [ "$SKIP_BUILD" = true ]; then
    print_warning "Skip build mode - assuming artifacts already exist"
fi

check_prerequisites

if [ "$SKIP_BUILD" = true ]; then
    verify_artifacts
else
    build_monorepo
    build_dynamic_plugins
fi

build_docker_image

echo ""
print_success "Build completed successfully!"
echo ""
print_status "To run the image:"
echo "  docker run -p 7007:7007 $IMAGE_NAME:latest"
