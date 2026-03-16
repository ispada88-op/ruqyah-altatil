# إنشاء Android Keystore لتوقيع التطبيق
# شغّل من مجلد المشروع: .\scripts\create_android_keystore.ps1

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$keystorePath = Join-Path $projectRoot "android\roqia.keystore"
Set-Location $projectRoot
$alias = "roqia"

Write-Host "=== إنشاء Android Keystore ===" -ForegroundColor Cyan
Write-Host "المسار: $keystorePath"
Write-Host "Alias: $alias"
Write-Host ""

if (Test-Path $keystorePath) {
    Write-Host "تحذير: الملف موجود مسبقاً. احذفه أولاً إن أردت إنشاء واحد جديد." -ForegroundColor Yellow
    exit 1
}

$cmd = "keytool -genkey -v -keystore $keystorePath -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias $alias"
Write-Host "تنفيذ: $cmd" -ForegroundColor Gray
Write-Host ""

Invoke-Expression $cmd

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "تم إنشاء Keystore بنجاح." -ForegroundColor Green
    Write-Host "1. ارفع الملف في Codemagic باسم: android_keystore"
    Write-Host "2. أو أنشئ key.properties محلياً للبناء:"
    Write-Host "   storePassword=كلمة_السر"
    Write-Host "   keyPassword=كلمة_السر"
    Write-Host "   keyAlias=$alias"
    Write-Host "   storeFile=roqia.keystore"
}
