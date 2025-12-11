#!/bin/bash

# Скрипт для швидкого старту розробки з hot reload
# Використання: ./start-dev.sh [backend|frontend|both]

set -e

# Кольори
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

MODE=${1:-both}

show_help() {
    echo -e "${BLUE}Використання:${NC}"
    echo -e "  ./start-dev.sh [backend|frontend|both]"
    echo ""
    echo -e "${BLUE}Режими:${NC}"
    echo -e "  ${GREEN}backend${NC}   - Запустити тільки backend в Docker"
    echo -e "  ${GREEN}frontend${NC}  - Запустити тільки frontend з hot reload"
    echo -e "  ${GREEN}both${NC}      - Запустити backend (Docker) + frontend (за замовчуванням)"
    echo ""
    echo -e "${BLUE}Приклади:${NC}"
    echo -e "  ./start-dev.sh           # Запустити все"
    echo -e "  ./start-dev.sh frontend  # Тільки frontend (якщо backend вже запущений)"
    echo -e "  ./start-dev.sh backend   # Тільки backend"
}

if [ "$MODE" = "help" ] || [ "$MODE" = "--help" ] || [ "$MODE" = "-h" ]; then
    show_help
    exit 0
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🔥 Karavan Development Mode с Hot Reload 🔥     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Функція для запуску backend
start_backend() {
    echo -e "${YELLOW}📦 Перевірка backend...${NC}"

    # Перевірка чи запущений контейнер
    if docker ps | grep -q karavan-backend; then
        echo -e "${GREEN}✅ Backend вже запущений${NC}"
    else
        echo -e "${YELLOW}🚀 Запуск backend в Docker...${NC}"

        # Перевірка чи існує образ
        if ! docker images | grep -q karavan-backend; then
            echo -e "${RED}❌ Docker образ не знайдено!${NC}"
            echo -e "${YELLOW}Запустіть спочатку: ./run-backend-docker.sh${NC}"
            exit 1
        fi

        ./backend.sh start

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Backend запущений на http://localhost:8080${NC}"
        else
            echo -e "${RED}❌ Помилка запуску backend${NC}"
            exit 1
        fi
    fi
}

# Функція для запуску frontend
start_frontend() {
    echo -e "${YELLOW}🎨 Запуск frontend з hot reload...${NC}"

    # Перевірка чи встановлені залежності
    if [ ! -d "karavan-app/src/main/webui/node_modules" ]; then
        echo -e "${YELLOW}📦 Встановлення залежностей...${NC}"
        cd karavan-app/src/main/webui
        npm install
        cd ../../..
    fi

    # Перевірка чи встановлений karavan-core
    if [ ! -d "karavan-core/node_modules" ]; then
        echo -e "${YELLOW}📦 Встановлення karavan-core...${NC}"
        cd karavan-core
        npm install
        cd ..
    fi

    echo ""
    echo -e "${GREEN}✨ Frontend запускається...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🌐 Відкрийте: ${BLUE}http://localhost:3003${NC}"
    echo -e "${GREEN}🔥 Hot Reload: ${BLUE}активний${NC}"
    echo -e "${GREEN}📡 Backend API: ${BLUE}http://localhost:8080${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Натисніть Ctrl+C для зупинки${NC}"
    echo ""

    cd karavan-app/src/main/webui
    npm run dev
}

# Головна логіка
case $MODE in
    backend)
        start_backend
        echo ""
        echo -e "${GREEN}✅ Backend запущений!${NC}"
        echo -e "${BLUE}Для запуску frontend виконайте: ./start-dev.sh frontend${NC}"
        ;;
    frontend)
        echo -e "${YELLOW}⚠️  Переконайтеся що backend запущений!${NC}"
        sleep 1
        start_frontend
        ;;
    both)
        start_backend
        echo ""
        sleep 2
        start_frontend
        ;;
    *)
        echo -e "${RED}❌ Невідомий режим: $MODE${NC}"
        show_help
        exit 1
        ;;
esac
