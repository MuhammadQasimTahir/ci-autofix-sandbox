@echo off
title n8n Local Server
set NGROK_DOMAIN=your-domain.ngrok-free.dev
set PG_PASSWORD=change-me

echo =================================================
echo   Starting n8n + Postgres + ngrok
echo =================================================

where ngrok >nul 2>&1
if errorlevel 1 (
    echo ERROR: ngrok is not installed or not on PATH.
    echo Run: winget install ngrok.ngrok
    pause
    exit /b 1
)

echo [1/4] Cleaning up old n8n container...
docker stop n8n cloudflare_tunnel >nul 2>&1
docker rm n8n cloudflare_tunnel >nul 2>&1

echo [2/4] Starting Postgres (audit log)...
docker start ci-audit-db >nul 2>&1
if errorlevel 1 (
    echo        First run - creating the ci-audit-db container...
    docker run -d --name ci-audit-db -e POSTGRES_USER=n8n -e POSTGRES_PASSWORD=%PG_PASSWORD% -e POSTGRES_DB=ci_audit -p 5432:5432 -v ci_audit_data:/var/lib/postgresql/data postgres:16 >nul
    if errorlevel 1 (
        echo ERROR: Failed to start Postgres. Is Docker Desktop running?
        pause
        exit /b 1
    )
)

echo [3/4] Starting n8n instance...
docker run -d --name n8n -p 5678:5678 -e WEBHOOK_URL=http://localhost:5678/ -e N8N_DIAGNOSTICS_ENABLED=false -e N8N_VERSION_NOTIFICATIONS_ENABLED=false -v n8n_data:/home/node/.n8n n8nio/n8n >nul
if errorlevel 1 (
    echo ERROR: Failed to start the n8n container. Is Docker Desktop running?
    pause
    exit /b 1
)

echo [4/4] Starting ngrok tunnel in a new window...
start "ngrok" ngrok http --domain=%NGROK_DOMAIN% 5678

echo.
echo =================================================
echo   Local URL:   http://localhost:5678
echo   Public URL:  https://%NGROK_DOMAIN%  (GitHub webhook only)
echo   Webhook:     https://%NGROK_DOMAIN%/webhook/ci-failure
echo   Postgres:    host.docker.internal:5432  db=ci_audit  user=n8n
echo =================================================
echo.
echo Keep the ngrok window open while you need webhooks.
echo Press any key to close this window...
pause >nul
