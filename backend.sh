#!/bin/bash

# Quick script to start/stop/restart Karavan backend in Docker

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONTAINER_NAME="karavan-backend"
IMAGE_NAME="karavan-backend:latest"

start_backend() {
    echo -e "${BLUE}Starting Karavan backend...${NC}"
    
    # Check if container exists and remove it
    if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
        echo "Removing existing container..."
        docker rm -f $CONTAINER_NAME
    fi
    
    # Start new container with minimal config for local development
    docker run -d \
        -p 8080:8080 \
        --name $CONTAINER_NAME \
        -e KARAVAN_ENVIRONMENT=local \
        -e KARAVAN_GIT_REPOSITORY=file:///deployments/karavan-data \
        -e KARAVAN_GIT_BRANCH=main \
        -v $(pwd)/karavan-data:/deployments/karavan-data \
        $IMAGE_NAME
    
    echo -e "${GREEN}✅ Backend started!${NC}"
    echo ""
    echo -e "${YELLOW}Backend URL: http://localhost:8080${NC}"
    echo -e "${YELLOW}View logs: docker logs -f $CONTAINER_NAME${NC}"
    echo ""
}

stop_backend() {
    echo -e "${BLUE}Stopping Karavan backend...${NC}"
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
        echo -e "${GREEN}✅ Backend stopped!${NC}"
    else
        echo -e "${YELLOW}Backend is not running${NC}"
    fi
}

status_backend() {
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo -e "${GREEN}✅ Backend is running${NC}"
        echo ""
        docker ps -f name=$CONTAINER_NAME
        echo ""
        echo -e "${YELLOW}Logs (last 20 lines):${NC}"
        docker logs --tail 20 $CONTAINER_NAME
    else
        echo -e "${RED}❌ Backend is not running${NC}"
    fi
}

logs_backend() {
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        docker logs -f $CONTAINER_NAME
    else
        echo -e "${RED}❌ Backend is not running${NC}"
    fi
}

case "$1" in
    start)
        start_backend
        ;;
    stop)
        stop_backend
        ;;
    restart)
        stop_backend
        sleep 2
        start_backend
        ;;
    status)
        status_backend
        ;;
    logs)
        logs_backend
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        echo ""
        echo "  start   - Start backend in Docker"
        echo "  stop    - Stop backend"
        echo "  restart - Restart backend"
        echo "  status  - Check backend status"
        echo "  logs    - Show backend logs (follow mode)"
        exit 1
        ;;
esac
