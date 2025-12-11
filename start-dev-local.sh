#!/bin/bash

# Скрипт для запуску повністю локальної розробки (Backend + Frontend локально)
# Backend буде в режимі Quarkus dev з автоматичною перекомпіляцією
# Frontend буде з Vite hot reload

set -e

# Кольори
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🔥 Karavan Full Local Dev (Backend + Frontend) ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Перевірка чи встановлений tmux
if ! command -v tmux &> /dev/null; then
    echo -e "${RED}❌ tmux не встановлений!${NC}"
    echo -e "${YELLOW}Встановіть tmux: brew install tmux${NC}"
    echo ""
    echo -e "${BLUE}Або запустіть вручну в двох терміналах:${NC}"
    echo -e "${GREEN}Термінал 1:${NC} cd karavan-app && mvn quarkus:dev -Dquarkus.profile=local,public"
    echo -e "${GREEN}Термінал 2:${NC} cd karavan-designer && npm run dev"
    exit 1
fi

# Перевірка чи встановлені залежності
echo -e "${YELLOW}📦 Перевірка залежностей...${NC}"

if [ ! -d "karavan-core/node_modules" ]; then
    echo -e "${YELLOW}Встановлення karavan-core...${NC}"
    cd karavan-core
    npm install
    cd ..
fi

if [ ! -d "karavan-app/src/main/webui/node_modules" ]; then
    echo -e "${YELLOW}Встановлення karavan-app webui...${NC}"
    cd karavan-app/src/main/webui
    npm install
    cd ../../..
fi

# Створення tmux сесії
SESSION_NAME="karavan-dev"

# Перевірка чи вже існує сесія
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Сесія '$SESSION_NAME' вже існує${NC}"
    echo -e "${BLUE}Підключіться: tmux attach -t $SESSION_NAME${NC}"
    echo -e "${BLUE}Або видаліть: tmux kill-session -t $SESSION_NAME${NC}"
    exit 1
fi

echo -e "${GREEN}🚀 Створення tmux сесії...${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎯 Backend Quarkus:${NC} порт 8080 (вікно 0)"
echo -e "${GREEN}🎨 Frontend Vite:${NC}   порт 3003 (вікно 1)"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Корисні tmux команди:${NC}"
echo -e "  ${GREEN}Ctrl+B 0${NC}     - перейти до backend"
echo -e "  ${GREEN}Ctrl+B 1${NC}     - перейти до frontend"
echo -e "  ${GREEN}Ctrl+B D${NC}     - відключитися (процеси продовжать працювати)"
echo -e "  ${GREEN}Ctrl+C${NC}       - зупинити процес у поточному вікні"
echo ""
echo -e "${BLUE}Для повернення в сесію: ${GREEN}tmux attach -t $SESSION_NAME${NC}"
echo -e "${BLUE}Для зупинки всього:     ${GREEN}tmux kill-session -t $SESSION_NAME${NC}"
echo ""
echo -e "${YELLOW}Запуск через 3 секунди...${NC}"
sleep 3

# Створення нової сесії з backend
tmux new-session -d -s $SESSION_NAME -n backend

# Налаштування першого вікна (Backend)
tmux send-keys -t $SESSION_NAME:0 "echo '🎯 Запуск Backend (Quarkus Dev Mode)...'" C-m
tmux send-keys -t $SESSION_NAME:0 "echo 'Hot reload: зміни в Java коді автоматично перекомпілюються'" C-m
tmux send-keys -t $SESSION_NAME:0 "echo ''" C-m
tmux send-keys -t $SESSION_NAME:0 "cd karavan-app" C-m
tmux send-keys -t $SESSION_NAME:0 "mvn clean compile quarkus:dev -Dquarkus.profile=local,public" C-m

# Створення другого вікна (Frontend)
tmux new-window -t $SESSION_NAME:1 -n frontend
tmux send-keys -t $SESSION_NAME:1 "echo '🎨 Запуск Frontend (Vite Dev Server)...'" C-m
tmux send-keys -t $SESSION_NAME:1 "echo 'Hot reload: зміни в React коді оновлюються миттєво'" C-m
tmux send-keys -t $SESSION_NAME:1 "echo ''" C-m
tmux send-keys -t $SESSION_NAME:1 "echo 'Очікування запуску backend...'" C-m
tmux send-keys -t $SESSION_NAME:1 "sleep 30" C-m
tmux send-keys -t $SESSION_NAME:1 "cd karavan-app/src/main/webui" C-m
tmux send-keys -t $SESSION_NAME:1 "npm run dev" C-m

# Підключення до сесії (frontend вікно)
echo -e "${GREEN}✅ Сесія створена!${NC}"
echo -e "${BLUE}Підключення до tmux...${NC}"
sleep 1

tmux select-window -t $SESSION_NAME:1
tmux attach-session -t $SESSION_NAME
