@echo off
REM ============================================================
REM  start_all.bat — GigShield Local Launcher
REM  Starts local processes only:
REM    4 backend services + API Gateway
REM    2 React frontends (worker-app, admin-dashboard)
REM
REM  Usage:
REM    start_all.bat          — Start all services + frontends (local mode)
REM    start_all.bat stop     — Stop local service/frontend windows started by this script
REM ============================================================

setlocal EnableDelayedExpansion

REM ── Paths ──
set BASE=%~dp0
set SERVICES=%BASE%services
set FRONTEND=%BASE%frontend

REM ── Colour helpers (works on Windows 10+) ──
set GREEN=[92m
set YELLOW=[93m
set RED=[91m
set CYAN=[96m
set RESET=[0m

echo.
echo %CYAN%  ██████╗ ██╗ ██████╗ ███████╗██╗  ██╗██╗███████╗██╗     ██████╗ %RESET%
echo %CYAN%  ██╔════╝██║██╔════╝ ██╔════╝██║  ██║██║██╔════╝██║     ██╔══██╗%RESET%
echo %CYAN%  ██║  ███╗██║██║  ███╗███████╗███████║██║█████╗  ██║     ██║  ██║%RESET%
echo %CYAN%  ██║   ██║██║██║   ██║╚════██║██╔══██║██║██╔══╝  ██║     ██║  ██║%RESET%
echo %CYAN%  ╚██████╔╝██║╚██████╔╝███████║██║  ██║██║███████╗███████╗██████╔╝%RESET%
echo %CYAN%   ╚═════╝ ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═════╝ %RESET%
echo %YELLOW%  AI-Powered Parametric Income Insurance — Guidewire Hackathon 2025%RESET%
echo.

REM ── Route to sub-command ──
if /i "%~1"=="stop"  goto :stop_all

REM ══════════════════════════════════════════════
REM  LOCAL MODE (default)
REM  Runs services via uvicorn and frontends via vite
REM ══════════════════════════════════════════════
:local_mode
echo %YELLOW%  LOCAL MODE — starting services with hot-reload (uvicorn + vite)%RESET%
echo.

REM ── Step 1: Copy .env.example to each service if .env missing ──
echo %GREEN%[1/3]%RESET% Preparing environment files...
for %%S in (identity-service insurance-core intelligence-service platform-service api-gateway) do (
    if not exist "%SERVICES%\%%S\.env" (
        if exist "%SERVICES%\%%S\.env.example" (
            copy "%SERVICES%\%%S\.env.example" "%SERVICES%\%%S\.env" >nul
            echo       Created .env for %%S from .env.example
        )
    )
)

REM ── Step 2: Start Python services ──
echo.
echo %GREEN%[2/3]%RESET% Starting backend services...
echo       Port map:
echo         8000  API Gateway
echo         8001  Identity Service     (auth, KYC, OTP)
echo         8002  Insurance Core       (policy, claims, payout)
echo         8003  Intelligence Service (fraud, risk, disruption)
echo         8004  Platform Service     (notifications, analytics)
echo.
start "GigShield — api-gateway"           cmd /k "cd /d %SERVICES%\api-gateway && pip install -r requirements.txt -q && uvicorn main:app --host 0.0.0.0 --port 8000 --reload"
start "GigShield — identity-service"      cmd /k "cd /d %SERVICES%\identity-service && pip install -r requirements.txt -q && uvicorn main:app --host 0.0.0.0 --port 8001 --reload"
start "GigShield — insurance-core"        cmd /k "cd /d %SERVICES%\insurance-core && pip install -r requirements.txt -q && uvicorn main:app --host 0.0.0.0 --port 8002 --reload"
start "GigShield — intelligence-service"  cmd /k "cd /d %SERVICES%\intelligence-service && pip install -r requirements.txt -q && uvicorn main:app --host 0.0.0.0 --port 8003 --reload"
start "GigShield — platform-service"      cmd /k "cd /d %SERVICES%\platform-service && pip install -r requirements.txt -q && uvicorn main:app --host 0.0.0.0 --port 8004 --reload"

REM ── Step 3: Start frontends ──
echo.
echo %GREEN%[3/3]%RESET% Starting frontends...
echo         3000  Worker App      (React PWA)
echo         3001  Admin Dashboard (React)
echo.
start "GigShield — worker-app"      cmd /k "cd /d %FRONTEND%\worker-app      && npm install && npm run dev -- --port 3000"
start "GigShield — admin-dashboard" cmd /k "cd /d %FRONTEND%\admin-dashboard && npm install && npm run dev -- --port 3001"

goto :print_urls

REM ══════════════════════════════════════════════
REM  STOP — close local windows started by this script
REM ══════════════════════════════════════════════
:stop_all
echo %YELLOW%  Stopping local GigShield windows...%RESET%
taskkill /FI "WINDOWTITLE eq GigShield — api-gateway" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq GigShield — identity-service" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq GigShield — insurance-core" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq GigShield — intelligence-service" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq GigShield — platform-service" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq GigShield — worker-app" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq GigShield — admin-dashboard" /T /F >nul 2>&1
echo %GREEN%  Stop signal sent to all local windows.%RESET%
pause
exit /b 0

REM ══════════════════════════════════════════════
REM  URL SUMMARY
REM ══════════════════════════════════════════════
:print_urls
echo.
echo %GREEN%  ✓ GigShield is starting up!%RESET%
echo.
echo %CYAN%  ── Frontend URLs ────────────────────────────────%RESET%
echo    Worker App        http://localhost:3000
echo    Admin Dashboard   http://localhost:3001
echo.
echo %CYAN%  ── API Gateway ──────────────────────────────────%RESET%
echo    API Base URL      http://localhost:8000/api/v1
echo    Gateway Health    http://localhost:8000/health
echo.
echo %CYAN%  ── Service Swagger Docs ──────────────────────────%RESET%
echo    Identity Service     http://localhost:8001/docs
echo    Insurance Core       http://localhost:8002/docs
echo    Intelligence Service http://localhost:8003/docs
echo    Platform Service     http://localhost:8004/docs
echo.
echo %YELLOW%  Run  start_all.bat stop   to close all started windows%RESET%
echo.

REM Open browser tabs (comment these out if not wanted)
timeout /t 5 /nobreak >nul
start "" "http://localhost:3000"
start "" "http://localhost:3001"

pause
exit /b 0

REM ══════════════════════════════════════════════
:error
echo.
echo %RED%  ERROR: Something went wrong. Check the output above.%RESET%
echo %YELLOW%  Try:  docker compose logs  to see error details%RESET%
pause
exit /b 1
