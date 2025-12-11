#!/bin/bash

# Script to build and run Karavan backend in Docker
# Frontend will run separately with npm run dev

set -e

echo "🚀 Building Karavan backend for Docker..."

# Set Java home (use Java 17+)
export JAVA_HOME="/opt/homebrew/Cellar/openjdk@17/17.0.15/libexec/openjdk.jdk/Contents/Home"
export PATH="/opt/homebrew/bin:$JAVA_HOME/bin:$PATH"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Step 1: Generate Camel models${NC}"
./karavan-generator/mvnw clean compile exec:java -Dexec.mainClass="org.apache.camel.karavan.generator.KaravanGenerator" -f karavan-generator || /opt/homebrew/bin/mvn clean compile exec:java -Dexec.mainClass="org.apache.camel.karavan.generator.KaravanGenerator" -f karavan-generator

echo -e "${BLUE}Step 2: Build and install karavan-core${NC}"
cd karavan-core
npm install
cd ..

echo -e "${BLUE}Step 3: Build Quarkus backend${NC}"
cd karavan-app
./mvnw clean package -Dquarkus.package.type=uber-jar || /opt/homebrew/bin/mvn clean package -Dquarkus.package.type=uber-jar
cd ..

echo -e "${BLUE}Step 4: Build Docker image${NC}"
cd karavan-app
docker build -f src/main/docker/Dockerfile -t karavan-backend:latest .
cd ..

echo -e "${GREEN}✅ Docker image built successfully!${NC}"
echo ""
echo -e "${YELLOW}To run the backend:${NC}"
echo "  docker run -d -p 8080:8080 --name karavan-backend karavan-backend:latest"
echo ""
echo -e "${YELLOW}To stop the backend:${NC}"
echo "  docker stop karavan-backend && docker rm karavan-backend"
echo ""
echo -e "${YELLOW}To view logs:${NC}"
echo "  docker logs -f karavan-backend"
