@ECHO OFF
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Command Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy RemoteSigned -Command "& '%~dpn0.ps1' %*"
