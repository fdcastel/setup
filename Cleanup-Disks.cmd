@ECHO OFF
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
IF ERRORLEVEL 1 PAUSE & EXIT /B 1
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy RemoteSigned -Command "& '%~dpn0.ps1' %*"
IF ERRORLEVEL 1 PAUSE & EXIT /B 1
