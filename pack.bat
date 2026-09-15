@echo off
chcp 65001 >nul
cd /d "%~dp0"
if /i "%~1"=="help" goto :help
if /i "%~1"=="-help" goto :help
if /i "%~1"=="/?" goto :help
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\pack.ps1" %*
exit /b %ERRORLEVEL%

:help
echo.
echo  新生儿护理工作台 · 打包
echo.
echo  pack.bat              按提示改配置，打后端 + PC 前端 + Android
echo  pack.bat -Yes         不提问，直接用 scripts\pack.config.ps1
echo  pack.bat -Target web  只打 PC 前端
echo  pack.bat -ConfigOnly  只改配置，不编译
echo.
echo  -Target 可选: all ^| server ^| backend ^| web ^| android
echo  server = 后端 + PC，不要 APK
echo.
exit /b 0
