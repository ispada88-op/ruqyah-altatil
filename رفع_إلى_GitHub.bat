@echo off
cd /d "%~dp0"

set /p USERNAME="GitHub Username (e.g. ispada88-op): "
if "%USERNAME%"=="" (
  echo No username. Exit.
  pause
  exit /b 1
)

echo.
echo Connecting and pushing...
echo When asked for password, paste your Personal Access Token (not account password).
echo.

git remote remove origin 2>nul
git remote add origin https://github.com/%USERNAME%/ruqyah-altatil.git
git push -u origin main

echo.
if %ERRORLEVEL% EQU 0 (
  echo Done: https://github.com/%USERNAME%/ruqyah-altatil
) else (
  echo Failed. Create repo ruqyah-altatil on GitHub and use Token as password.
)
echo.
pause
