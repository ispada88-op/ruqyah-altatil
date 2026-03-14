@echo off
chcp 65001 >nul
echo ========================================
echo   رفع مشروع الرقية إلى GitHub
echo ========================================
echo.

cd /d "%~dp0"

set /p USERNAME="ادخل اسم المستخدم في GitHub (Username): "
if "%USERNAME%"=="" (
  echo لم تدخل اسم المستخدم. ألغيت.
  pause
  exit /b 1
)

echo.
echo جاري ربط المستودع وإرسال الكود...
echo عند الطلب: كلمة المرور = Personal Access Token من GitHub
echo    (ليس كلمة مرور حسابك)
echo.

git remote remove origin 2>nul
git remote add origin https://github.com/%USERNAME%/ruqyah-altatil.git
git push -u origin main

echo.
if %ERRORLEVEL% EQU 0 (
  echo تم الرفع بنجاح.
  echo الرابط: https://github.com/%USERNAME%/ruqyah-altatil
) else (
  echo فشل الرفع. تأكد من:
  echo 1- إنشاء مستودع ruqyah-altatil على GitHub
  echo 2- استخدام Token ككلمة مرور: GitHub ^> Settings ^> Developer settings ^> Personal access tokens
)
echo.
pause
