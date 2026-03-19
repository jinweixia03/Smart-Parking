@echo off
chcp 65001 >nul
echo ============================================
echo  Smart Parking - Build Docker Image
echo ============================================

set IMAGE_NAME=smart-parking
set IMAGE_TAG=latest
set OUTPUT_FILE=smart-parking.tar

echo [1/2] Building image (this may take 10-20 minutes)...
docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo [2/2] Exporting image to %OUTPUT_FILE%...
docker save -o %OUTPUT_FILE% %IMAGE_NAME%:%IMAGE_TAG%
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Export failed!
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Done! File: %OUTPUT_FILE%
echo ============================================
echo.
echo  Share this file, then on any machine run:
echo  docker load -i smart-parking.tar
echo  docker run -d -p 3000:3000 --name parking smart-parking
echo  Open: http://localhost:3000
echo ============================================
pause
