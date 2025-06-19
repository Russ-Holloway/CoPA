@echo off
echo Updating deployment templates and generating deployment URL...
powershell -ExecutionPolicy Bypass -File "%~dp0update_deploy_template.ps1"
echo.
echo If the script completed successfully, you'll find your deployment URL in azure_deploy_url.txt
pause
