#!/bin/bash
set -e

# Update Base Image Script
# Fetches the latest UBI10 Node.js 22 image tag from Red Hat registry,
# updates the Dockerfile, and rebuilds the image.
#
# Usage:
#   ./scripts/update-base-image.sh [OPTIONS]
#
# Options:
#   --no-build       Skip the Docker image build step
#   --help, -h       Show help message

# Configuration
DOCKERFILE_PATH="packages/backend/Dockerfile"
REGISTRY="registry.redhat.io/ubi10/nodejs-22"
TAG_PREFIX="10.1-"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
SKIP_BUILD=false

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

show_help() {
    echo "Update Base Image Script"
    echo ""
    echo "Fetches the latest UBI10 Node.js 22 image tag from Red Hat registry,"
    echo "updates the Dockerfile, and rebuilds the image."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --no-build       Skip the Docker image build step"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                # Update and rebuild"
    echo "  $0 --no-build     # Update Dockerfile only, skip build"
}

check_prerequisites() {
    print_status "Checking prerequisites..."

    if ! command -v skopeo &> /dev/null; then
        print_error "skopeo is not installed or not in PATH"
        echo "  Install with: brew install skopeo (macOS) or dnf install skopeo (RHEL/Fedora)"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed or not in PATH"
        echo "  Install with: brew install jq (macOS) or dnf install jq (RHEL/Fedora)"
        exit 1
    fi

    if [ ! -f "$DOCKERFILE_PATH" ]; then
        print_error "Dockerfile not found at $DOCKERFILE_PATH"
        exit 1
    fi

    print_success "Prerequisites met"
}

get_current_tag() {
    # Extract current tag from Dockerfile FROM line
    # Example: FROM registry.redhat.io/ubi9/nodejs-22:9.7-1765878606
    grep "^FROM $REGISTRY:" "$DOCKERFILE_PATH" | sed "s|FROM $REGISTRY:||"
}

get_latest_tag() {
    local latest_tag
    latest_tag=$(skopeo list-tags "docker://$REGISTRY" 2>/dev/null \
        | jq -r ".Tags[]
                 | select(startswith(\"$TAG_PREFIX\"))
                 | select(endswith(\"-source\") | not)" \
        | sort -V \
        | tail -n 1)

    if [ -z "$latest_tag" ]; then
        print_error "Failed to fetch latest tag from registry" >&2
        exit 1
    fi

    echo "$latest_tag"
}

update_dockerfile() {
    local current_tag="$1"
    local new_tag="$2"

    print_status "Updating Dockerfile..."

    # Use sed to replace the FROM line
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed requires empty string for -i
        sed -i '' "s|FROM $REGISTRY:$current_tag|FROM $REGISTRY:$new_tag|" "$DOCKERFILE_PATH"
    else
        # Linux sed
        sed -i "s|FROM $REGISTRY:$current_tag|FROM $REGISTRY:$new_tag|" "$DOCKERFILE_PATH"
    fi

    print_success "Dockerfile updated"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-build)
            SKIP_BUILD=true
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
echo -e "${GREEN}Update Base Image${NC}"
echo -e "${GREEN}==================${NC}"
echo ""

check_prerequisites

current_tag=$(get_current_tag)
print_status "Current image tag: $current_tag"

print_status "Fetching latest image tag from Red Hat registry..."
latest_tag=$(get_latest_tag)
print_status "Latest image tag:  $latest_tag"

if [ "$current_tag" = "$latest_tag" ]; then
    print_success "Already using the latest image tag. No update needed."
    exit 0
fi

echo ""
print_warning "New image version available!"
echo "  Current: $REGISTRY:$current_tag"
echo "  Latest:  $REGISTRY:$latest_tag"
echo ""

update_dockerfile "$current_tag" "$latest_tag"

# Verify the update
new_current=$(get_current_tag)
if [ "$new_current" = "$latest_tag" ]; then
    print_success "Dockerfile successfully updated to $latest_tag"
else
    print_error "Failed to update Dockerfile"
    exit 1
fi

if [ "$SKIP_BUILD" = true ]; then
    print_warning "Skipping Docker image build (--no-build)"
    echo ""
    print_status "To build the image manually, run:"
    echo "  ./scripts/build-local-image.sh --quick"
else
    echo ""
    print_status "Building Docker image..."
    echo ""

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    "$SCRIPT_DIR/build-local-image.sh" --quick
fi

echo ""
print_success "Base image update completed!"
echo ""
echo "Summary:"
echo "  Old tag: $current_tag"
echo "  New tag: $latest_tag"
