@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0{{TOOL}}.ps1" %*
set exitcode=%errorlevel%
exit /b %exitcode%
