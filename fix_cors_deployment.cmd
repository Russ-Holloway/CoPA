@echo off
echo Running CORS fix for Azure deployment...
powershell -ExecutionPolicy Bypass -File "%~dp0fix_cors_deployment.ps1"
echo.
echo If the script completed successfully, you'll find your deployment URL in the azure_deployment_url.txt file.
echo.
pause
