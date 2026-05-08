@echo off
REM ─────────────────────────────────────────────────────────────────────
REM Windows audio compression script
REM Requires ffmpeg in PATH (install via: winget install ffmpeg)
REM ─────────────────────────────────────────────────────────────────────

where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] ffmpeg not found in PATH
    echo Install with: winget install ffmpeg
    pause
    exit /b 1
)

if not exist "assets\audio\_original_backup" mkdir "assets\audio\_original_backup"

for %%f in (assets\audio\*.mp3) do (
    echo Compressing: %%~nxf
    copy "%%f" "assets\audio\_original_backup\%%~nxf" >nul
    ffmpeg -y -i "assets\audio\_original_backup\%%~nxf" -ac 1 -ar 22050 -b:a 64k -map_metadata -1 "%%f" 2>nul
    echo    Done: %%~nxf
)

echo.
echo Compression finished. Originals in assets\audio\_original_backup\
pause
