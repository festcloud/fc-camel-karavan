# 🔥 Гайд по локальній розробці з Live Reload (Hot Reload)

## Проблема

Коли ви збираєте Docker образ, весь код (frontend + backend) упаковується в контейнер. Під час розробки зміни в коді не відображаються автоматично, доки ви не пересібілдите образ.

## Рішення: Окремий запуск Frontend і Backend

Для комфортної розробки потрібно запускати **фронтенд і бекенд окремо**:

- **Frontend (React + Vite)** - запускається локально з hot reload на порту **3003**
- **Backend (Quarkus)** - може бути в Docker або локально на порту **8080**

---

## ✅ Варіант 1: Frontend локально + Backend в Docker (Рекомендовано)

### Переваги:
- Фронтенд оновлюється миттєво при збереженні файлів
- Бекенд ізольований в Docker
- Не потрібно налаштовувати Java/Maven для повсякденної розробки UI

### Крок 1: Підготовка (тільки один раз)

```bash
# Генерація Camel Models
mvn clean compile exec:java -Dexec.mainClass="org.apache.camel.karavan.generator.KaravanGenerator" -f karavan-generator

# Встановлення karavan-core
cd karavan-core
npm install
cd ..

# Збудувати Docker образ бекенду
./run-backend-docker.sh
```

### Крок 2: Запустити бекенд в Docker

```bash
./backend.sh start
```

### Крок 3: Налаштувати proxy для frontend

Потрібно додати proxy конфігурацію в `karavan-designer/vite.config.ts`:

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import viteTsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
    base: '/',
    plugins: [react(), viteTsconfigPaths()],
    server: {
        open: true,
        port: 3003,
        proxy: {
            '/api': {
                target: 'http://localhost:8080',
                changeOrigin: true
            },
            '/public': {
                target: 'http://localhost:8080',
                changeOrigin: true
            },
            '/ui': {
                target: 'http://localhost:8080',
                changeOrigin: true
            }
        }
    }
})
```

### Крок 4: Запустити frontend з hot reload

```bash
cd karavan-designer
npm run dev
```

Відкрийте http://localhost:3003 - тепер будь-які зміни в файлах автоматично оновлюються в браузері! 🔥

---

## ✅ Варіант 2: Frontend + Backend локально (Hot Reload для обох)

### Переваги:
- Hot reload і для фронтенду, і для бекенду
- Найшвидша розробка
- Можна дебажити Java код

### Крок 1: Підготовка (тільки один раз)

```bash
# Генерація Camel Models
mvn clean compile exec:java -Dexec.mainClass="org.apache.camel.karavan.generator.KaravanGenerator" -f karavan-generator

# Встановлення karavan-core
cd karavan-core
npm install
cd ..
```

### Крок 2: Запустити backend в dev режимі

```bash
cd karavan-app
mvn clean compile quarkus:dev -Dquarkus.profile=local,public
```

Quarkus буде автоматично перезавантажувати зміни в Java коді!

### Крок 3: Запустити frontend в окремому терміналі

```bash
cd karavan-designer
npm run dev
```

Відкрийте http://localhost:3003 - фронтенд буде проксувати запити до бекенду на порту 8080!

---

## 🎯 Workflow розробки

### Розробка Frontend

```bash
# Термінал 1: Backend (Docker або локально)
./backend.sh start
# або
cd karavan-app && mvn quarkus:dev -Dquarkus.profile=local,public

# Термінал 2: Frontend з hot reload
cd karavan-designer
npm run dev
```

Тепер ви можете:
- Редагувати файли в `karavan-designer/src/`
- Зміни автоматично відображаються в браузері
- Зберігаєте файл (Cmd+S) → бачите зміни через 100-500ms

### Розробка Backend

```bash
# Термінал 1: Backend локально
cd karavan-app
mvn quarkus:dev -Dquarkus.profile=local,public

# Термінал 2: Frontend
cd karavan-designer
npm run dev
```

Тепер ви можете:
- Редагувати Java файли в `karavan-app/src/main/java/`
- Quarkus автоматично перекомпілює при збереженні
- API endpoint змінюються без перезапуску

---

## 🔧 Налаштування CORS (якщо потрібно)

Якщо виникають CORS помилки, додайте в `karavan-app/src/main/resources/application.properties`:

```properties
# CORS для локальної розробки
%local.quarkus.http.cors=true
%local.quarkus.http.cors.origins=http://localhost:3003
%local.quarkus.http.cors.methods=GET,POST,PUT,DELETE,PATCH,OPTIONS
%local.quarkus.http.cors.headers=accept,authorization,content-type,x-requested-with
```

---

## 📊 Структура портів

```
┌──────────────────┐
│   Browser        │
│ localhost:3003   │  ← Vite Dev Server (Frontend з Hot Reload)
└────────┬─────────┘
         │ Proxy API requests
         ▼
┌──────────────────┐
│ Backend          │
│ localhost:8080   │  ← Quarkus (Docker або локально)
└──────────────────┘
```

---

## 🐛 Troubleshooting

### 1. Frontend не підключається до Backend

```bash
# Перевірте чи запущений backend
curl http://localhost:8080/public/configuration

# Подивіться логи backend
./backend.sh logs
```

### 2. Зміни в frontend не відображаються

```bash
# Переконайтеся що Vite dev server запущений
cd karavan-designer
npm run dev

# Перевірте консоль браузера на помилки
```

### 3. Backend не перезавантажує зміни

```bash
# Переконайтеся що використовуєте quarkus:dev
cd karavan-app
mvn clean compile quarkus:dev -Dquarkus.profile=local,public

# НЕ робіть просто mvn package - це production білд без hot reload
```

### 4. Порт 3003 або 8080 зайнятий

```bash
# Знайти процес на порту
lsof -i :3003
lsof -i :8080

# Вбити процес
kill -9 <PID>
```

---

## 🎨 Корисні команди

### Перезапустити тільки Frontend

```bash
# У терміналі з npm run dev натисніть Ctrl+C, потім:
npm run dev
```

### Перезапустити тільки Backend (Docker)

```bash
./backend.sh restart
```

### Перезапустити тільки Backend (локальний)

```bash
# У терміналі з mvn quarkus:dev натисніть 'r' або Ctrl+C, потім:
mvn quarkus:dev -Dquarkus.profile=local,public
```

### Очистити все і почати з нуля

```bash
# Очистити karavan-core
cd karavan-core
rm -rf node_modules package-lock.json
npm install

# Очистити karavan-designer
cd ../karavan-designer
rm -rf node_modules package-lock.json
npm install

# Очистити backend
cd ../karavan-app
mvn clean
```

---

## 📁 Структура проекту для розробки

```
fc-camel-karavan/
├── karavan-generator/          # Генератор моделей (запускається один раз)
├── karavan-core/               # Бібліотека (npm install один раз)
├── karavan-designer/           # 🔥 Frontend з hot reload (розробка тут)
│   ├── src/
│   │   ├── designer/           # Основний UI
│   │   ├── topology/           # Топологія
│   │   └── ...
│   ├── vite.config.ts          # Налаштування Vite + Proxy
│   └── package.json
└── karavan-app/                # Backend (Quarkus)
    ├── src/main/java/          # Java код (розробка тут якщо backend)
    ├── src/main/resources/
    │   └── application.properties
    └── pom.xml
```

---

## 🚀 Швидкий старт (TL;DR)

```bash
# 1. Підготовка (один раз)
mvn clean compile exec:java -Dexec.mainClass="org.apache.camel.karavan.generator.KaravanGenerator" -f karavan-generator
cd karavan-core && npm install && cd ..
./run-backend-docker.sh

# 2. Запуск для розробки (кожного разу)
# Термінал 1: Backend
./backend.sh start

# Термінал 2: Frontend з hot reload
cd karavan-designer && npm run dev
```

Відкрийте http://localhost:3003 і насолоджуйтесь розробкою! 🎉

---

## 📝 Коли потрібно пересібілдити Backend Docker образ?

Тільки коли змінюєте **Java код** або **конфігурацію**:

- Змінили файли в `karavan-app/src/main/java/`
- Змінили `application.properties`
- Оновили залежності в `pom.xml`

```bash
./backend.sh stop
./run-backend-docker.sh
./backend.sh start
```

**НЕ потрібно** пересібілдити Docker образ для змін у frontend!

---

## 🎯 Висновок

- **Frontend розробка**: завжди використовуйте `npm run dev` в `karavan-designer/`
- **Backend розробка**: використовуйте `mvn quarkus:dev` для hot reload Java коду
- **Тільки frontend**: backend може бути в Docker
- **Frontend + Backend**: обидва локально для найкращого dev experience

**Happy Coding! 🔥**
