# 🚀 Швидкий старт Camel Karavan для розробки (Українською)

## 📋 Передумови
- ✅ Java 17+
- ✅ Maven 3.8+
- ✅ Node.js 22+
- ✅ Docker Engine 24+ (для локального тестування)

## 🐳 Варіант 1: Бекенд в Docker (Рекомендовано)

### Переваги:
- ✅ Ізоляція бекенду в контейнері
- ✅ Не потрібно локально налаштовувати Java/Maven для запуску
- ✅ Легше відтворити production environment
- ✅ Швидший перезапуск бекенду

### Крок 1: Перший запуск - Збудувати Docker образ

```bash
./run-backend-docker.sh
```

Цей скрипт:
1. Згенерує моделі Camel
2. Встановить karavan-core
3. Збудує Quarkus додаток (uber-jar)
4. Створить Docker образ `karavan-backend:latest`

⏱️ Перший білд займе ~5-10 хвилин

### Крок 2: Запустити бекенд

```bash
./backend.sh start
```

### Крок 3: Запустити фронтенд

```bash
cd karavan-designer
npm run dev
```

Відкрийте http://localhost:5173 - тепер фронтенд буде комунікувати з бекендом в Docker!

### Команди управління бекендом:

```bash
./backend.sh start    # Запустити
./backend.sh stop     # Зупинити
./backend.sh restart  # Перезапустити
./backend.sh status   # Статус і останні логи
./backend.sh logs     # Переглядати логи в реальному часі
```

### Корисні Docker команди:

```bash
# Переглянути запущені контейнери
docker ps

# Зупинити бекенд
docker stop karavan-backend

# Переглянути логи
docker logs -f karavan-backend

# Видалити контейнер
docker rm karavan-backend

# Видалити образ (якщо потрібно пересібілдити)
docker rmi karavan-backend:latest
```

### Коли потрібно пересібілдити Docker образ?

Після змін в:
- Java/Quarkus коді (`karavan-app/src/main/java`)
- Конфігурації (`application.properties`)
- Залежностей (`pom.xml`)

```bash
# Зупинити старий контейнер
./backend.sh stop

# Пересібілдити
./run-backend-docker.sh

# Запустити новий
./backend.sh start
```

---

## 💻 Варіант 2: Локальний запуск (Без Docker)

### Якщо ви хочете розробляти бекенд локально:

```bash
cd karavan-app
mvn clean compile quarkus:dev -Dquarkus.profile=local,public
```

### Крок 4: Відкрити в браузері

Перейдіть на: **http://localhost:8080**

---

## 🔥 Режим розробки з Live Reload

Quarkus автоматично перезавантажує зміни:

- ✅ **Java код**: автоматично компілюється при збереженні
- ✅ **Frontend (React)**: hot reload через Quinoa (працює на порті 3003)
- ✅ **Resources**: автоматично оновлюються

### Як це працює:

1. Відредагуйте будь-який файл в `karavan-app/src`
2. Збережіть файл (Cmd+S)
3. Quarkus автоматично виявить зміни та перезавантажить
4. Оновіть браузер - побачите зміни! 🎉

---

## 🛠️ Додаткові налаштування для повної функціональності

### Оновити файл `/etc/hosts` (потрібно для Git та Registry):

```bash
sudo nano /etc/hosts
```

Додайте ці рядки:

```
127.0.0.1	gitea
127.0.0.1   registry
```

Збережіть (Ctrl+O, Enter, Ctrl+X)

---

## 📊 Корисні команди під час розробки

### Перевірити статус Docker
```bash
docker ps
```

### Переглянути логи Quarkus
Логи автоматично виводяться в консолі де запущено `quarkus:dev`

### Очистити та перебудувати проект
```bash
mvn clean compile -f karavan-app
```

### Доступ до Quarkus Dev UI
http://localhost:8080/q/dev

---

## 🎯 Структура портів

- **8080** - Karavan Application (головний інтерфейс)
- **3003** - Frontend Dev Server (Quinoa/React)
- **5005** - Java Debug Port (для підключення дебагера)

---

## 🐛 Налагодження (Debugging)

### VS Code

Додайте в `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "java",
      "name": "Debug Karavan",
      "request": "attach",
      "hostName": "localhost",
      "port": 5005
    }
  ]
}
```

Потім:
1. Запустіть `mvn quarkus:dev`
2. У VS Code натисніть F5
3. Встановіть точки зупинки в коді

---

## 🎨 Розробка Frontend

Якщо ви хочете працювати тільки з UI:

```bash
cd karavan-space  # або karavan-designer
npm install
npm run dev
```

Frontend буде доступний на порті, вказаному в консолі.

---

## 🌐 Архітектура розробки

```
┌─────────────────┐
│   Browser       │
│  localhost:5173 │  ← Фронтенд (Vite dev server)
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────┐
│  Docker         │
│  localhost:8080 │  ← Бекенд (Quarkus в контейнері)
└─────────────────┘
```

## 🐛 Troubleshooting

### Бекенд не відповідає

```bash
# Перевірити чи запущений контейнер
docker ps | grep karavan

# Подивитись логи
./backend.sh logs

# Перезапустити
./backend.sh restart
```

### CORS помилки

Переконайтеся що в `application.properties` правильно налаштовано CORS:

```properties
quarkus.http.cors=true
quarkus.http.cors.origins=http://localhost:5173
```

### Порт 8080 зайнятий

```bash
# Знайти процес на порту 8080
lsof -i :8080

# Або змінити порт в Docker
docker run -p 8081:8080 ...
```

### Docker образ не білдиться

```bash
# Очистити Maven кеш і target
cd karavan-app
./mvnw clean
rm -rf target

# Спробувати знову
cd ..
./run-backend-docker.sh
```

---

## 🎉 Готово!

Тепер ви можете:
1. ✅ Редагувати код в реальному часі
2. ✅ Бачити зміни без перезапуску
3. ✅ Дебажити через IDE
4. ✅ Тестувати на localhost

**Happy Coding! 🚀**
