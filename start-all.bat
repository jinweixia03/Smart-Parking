@echo off
chcp 936 >nul
echo ============================================
echo Smart Parking System - Startup Script
echo ============================================
echo.

REM Set variables
set "BACKEND_DIR=D:\1_Source\BSYCode\backend"
set "FRONTEND_DIR=D:\1_Source\BSYCode\frontend"
set "MAVEN_CMD=D:\Environments\maven\apache-maven-3.9.10\bin\mvn.cmd"
set "BACKEND_PORT=8080"
set "FRONTEND_PORT=3000"

REM Check environment
echo [Check environment...]

java -version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Java not found
    pause
    exit /b 1
)
echo [OK] Java

if not exist "%MAVEN_CMD%" (
    echo [ERROR] Maven not found
    pause
    exit /b 1
)
echo [OK] Maven

node --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js not found
    pause
    exit /b 1
)
echo [OK] Node.js

REM Stop old services
echo.
echo [Stop old services...]

taskkill /F /FI "WINDOWTITLE eq SmartParking*" >nul 2>&1
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM javaw.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1

echo [Check port %BACKEND_PORT%]...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%BACKEND_PORT%" ^| findstr "LISTENING" 2^>nul') do (
    echo [Stop PID: %%a]
    taskkill /F /PID %%a >nul 2>&1
)

echo [Check port %FRONTEND_PORT%]...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%FRONTEND_PORT%" ^| findstr "LISTENING" 2^>nul') do (
    echo [Stop PID: %%a]
    taskkill /F /PID %%a >nul 2>&1
)

timeout /t 3 /nobreak >nul
echo [OK] Old services stopped

REM Start backend
echo.
echo ============================================
echo [1/2] Start Backend
===========================================
echo.

cd /d "%BACKEND_DIR%"

if exist "target\classes" (
    echo [Found compiled code, start directly]
) else (
    echo [First run, compiling...]
    call "%MAVEN_CMD%" compile -q -DskipTests
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Compile failed
        pause
        exit /b 1
    )
    echo [OK] Compile success
)

echo [Start backend...]
start "SmartParking Backend" cmd /c "cd /d "%BACKEND_DIR%" && "%MAVEN_CMD%" spring-boot:run -DskipTests"

echo [Wait 5 seconds...]
timeout /t 5 /nobreak >nul
echo [OK] Backend started

REM Start frontend
echo.
echo ============================================
echo [2/2] Start Frontend
echo ============================================
echo.

cd /d "%FRONTEND_DIR%"

if not exist "node_modules" (
    echo [Install npm packages...]
    call npm install
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] npm install failed
        pause
        exit /b 1
    )
)

echo [Start frontend...]
start "SmartParking Frontend" cmd /c "cd /d "%FRONTEND_DIR%" && npm run dev"

echo [Wait 5 seconds...]
timeout /t 5 /nobreak >nul
echo [OK] Frontend started

REM Complete
echo.
echo ============================================
echo [OK] Services started!
echo ============================================
echo.
echo Access URL:
echo   Frontend: http://localhost:%FRONTEND_PORT%
echo   Backend:  http://localhost:%BACKEND_PORT%/api
echo.
echo Login:
echo   admin / admin123
echo   operator / admin123
echo.
echo [Press any key to stop all services]
echo.

pause >nul

REM Stop services
echo.
echo [Stopping services...]

taskkill /F /FI "WINDOWTITLE eq SmartParking*" >nul 2>&1
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM javaw.exe >nul 2>&1
taskkill /F /IM node.exe >nul 2>&1

for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%BACKEND_PORT%" ^| findstr "LISTENING" 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%FRONTEND_PORT%" ^| findstr "LISTENING" 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)

echo [OK] Services stopped
timeout /t 2 /nobreak >nul
