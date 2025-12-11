# 🚀 Karavan Development Cheat Sheet

## Quick Start (з Hot Reload!)

### First Time Setup:
```bash
./run-backend-docker.sh    # Build Docker image (~5-10 min)
./start-dev.sh            # Start backend + frontend з hot reload
```

### Daily Development:

#### Start Everything (Автоматично):
```bash
./start-dev.sh            # Backend (Docker) + Frontend (hot reload)
./start-dev-local.sh      # Backend + Frontend локально (hot reload обох)
```

#### Start Manually:
```bash
# Backend locally (Quarkus dev mode)
cd karavan-app && mvn quarkus:dev -Dquarkus.profile=local,public

# Frontend (в іншому терміналі)
cd karavan-app/src/main/webui && npm run dev
```

Open: http://localhost:3003 (з hot reload!) 🔥

#### Stop Everything:
```bash
./backend.sh stop
# Press Ctrl+C in frontend terminal
```

## Common Commands

### Backend (Docker):
```bash
./backend.sh start      # Start
./backend.sh stop       # Stop
./backend.sh restart    # Restart
./backend.sh status     # Status + logs
./backend.sh logs       # Live logs
```

### Frontend:
```bash
cd karavan-app/src/main/webui
npm run dev             # Start dev server
npm run build           # Build for production
npm run preview         # Preview production build
```

### Rebuild Backend (after code changes):
```bash
./backend.sh stop
./run-backend-docker.sh
./backend.sh start
```

## URLs

- **Frontend**: http://localhost:3003 (з hot reload!)
- **Backend API**: http://localhost:8080
- **Backend Health**: http://localhost:8080/q/health
- **Quarkus Dev UI**: http://localhost:8080/q/dev (якщо backend локально)

## Architecture

```
Browser (3003) → Vite Dev Server (hot reload) → Proxy → Backend API (8080)
```

## Troubleshooting

### Port already in use:
```bash
# Kill process on port 8080
lsof -i :8080
kill -9 <PID>

# Or use different port
docker run -p 8081:8080 ...
```

### Backend not responding:
```bash
./backend.sh status
./backend.sh logs
./backend.sh restart
```

### Frontend can't reach backend:
Check `karavan-app/src/main/resources/application.properties`:
```properties
%local.quarkus.http.cors=true
%local.quarkus.http.cors.origins=http://localhost:3003
```

Also check `karavan-designer/vite.config.ts` має proxy налаштування

### Rebuild from scratch:
```bash
./backend.sh stop
cd karavan-app
./mvnw clean
rm -rf target
cd ..
./run-backend-docker.sh
./backend.sh start
```

## File Structure

```
karavan-designer/
  src/
    designer/       # Designer UI components
    topology/       # Topology view
    Main.tsx        # Entry point

karavan-app/
  src/main/
    java/           # Backend code
    resources/      # Configuration
```

## Development Workflow

### 🔥 Hot Reload Mode:

1. **Frontend changes**:
   - Edit `karavan-designer/src/*`
   - Зберегти (Cmd+S)
   - → Миттєве оновлення в браузері! 🔥

2. **Backend changes (Docker)**:
   - Edit `karavan-app/src/main/java/*`
   - → Rebuild Docker → Restart
   ```bash
   ./backend.sh stop
   ./run-backend-docker.sh
   ./backend.sh start
   ```

3. **Backend changes (локальний Quarkus dev)**:
   - Edit `karavan-app/src/main/java/*`
   - Зберегти (Cmd+S)
   - → Quarkus автоматично перекомпілює! 🔥

## Performance Tips

- Keep Docker Desktop running
- Allocate enough resources (4GB+ RAM)
- Use `./backend.sh logs` to monitor performance
- Frontend hot-reload is instant
- Backend rebuild needed only for Java changes

## Help

- Logs: `./backend.sh logs`
- Status: `./backend.sh status`
- Docker: `docker ps`
- Build log: `tail -f build.log`
