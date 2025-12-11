# 🚀 Quick Start - Karavan Development

## 🎯 Режими розробки

### ✅ Full Local Dev (Backend + Frontend локально) - РЕКОМЕНДОВАНО

Для розробки backend з hot reload Java коду:

```bash
# Потрібен tmux (встановіть: brew install tmux)
./start-dev-local.sh
```

Відкрийте http://localhost:3003

**Що це дає:**
- ✅ Hot reload для frontend (React)
- ✅ Hot reload для backend (Java)
- ✅ Можливість дебажити Java код

**tmux команди:**
- `Ctrl+B 0` - перейти до backend вікна
- `Ctrl+B 1` - перейти до frontend вікна
- `Ctrl+B D` - відключитися (процеси продовжать працювати)
- `tmux attach -t karavan-dev` - повернутися в сесію
- `tmux kill-session -t karavan-dev` - зупинити все

---

### 3️⃣ Окремий запуск компонентів

#### Тільки Backend (Docker)

```bash
./start-dev.sh backend
```

#### Тільки Frontend

```bash
./start-dev.sh frontend
```

#### Backend локально (Quarkus dev mode)

```bash
cd karavan-app
mvn quarkus:dev -Dquarkus.profile=local,public
```

#### Frontend окремо

```bash
cd karavan-app/src/main/webui
npm run dev
```

---

## 📁 Де редагувати код?

### Frontend розробка
```
karavan-app/src/main/webui/src/
├── api/            # API клієнти
├── designer/       # Основний UI компонент дизайнера
├── topology/       # Топологія
├── main/           # Головні сторінки
└── ...
```

### Backend розробка
```
karavan-app/src/main/
├── java/           # Java код (REST API, бізнес-логіка)
└── resources/
    └── application.properties  # Конфігурація
```

---

## 🔄 Коли потрібно перезапускати?

### Frontend (karavan-designer)
**НЕ потрібно** перезапускати - hot reload працює автоматично!

### Backend (Docker)
Перезапустити тільки якщо змінили:
- Java код (`karavan-app/src/main/java/`)
- Конфігурацію (`application.properties`)
- Залежності (`pom.xml`)

```bash
./backend.sh stop
./run-backend-docker.sh
./backend.sh start
```

### Backend (локальний Quarkus dev)
**НЕ потрібно** перезапускати - Quarkus автоматично перекомпілює при збереженні!

---

## 🐛 Швидкі фікси

### Backend не відповідає
```bash
./backend.sh logs     # Подивитись логи
./backend.sh restart  # Перезапустити
```

### Frontend не підключається до backend
```bash
# Перевірити чи backend запущений
curl http://localhost:8080/public/configuration
```

### Порт зайнятий
```bash
lsof -i :3003  # Frontend
lsof -i :8080  # Backend
kill -9 <PID>  # Вбити процес
```

---

## 📚 Детальні гайди

- [LOCAL_DEV_GUIDE_UA.md](docs/LOCAL_DEV_GUIDE_UA.md) - Повний гайд по локальній розробці
- [QUICKSTART_DEV_UA.md](QUICKSTART_DEV_UA.md) - Оригінальний гайд з Docker
- [DEV.md](docs/DEV.md) - Документація для збірки проекту

---

## ⚡ TL;DR - Найшвидший старт

```bash
# Перший раз
./run-backend-docker.sh

# Кожного дня
./start-dev.sh

# Відкрити http://localhost:3003 і кодити! 🔥
```
