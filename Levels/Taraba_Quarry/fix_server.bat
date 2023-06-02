cd /d "%~dp0"
7z x "server.zip" -o"server" -y -xr!"vehicles" -xr!"effects\vehicles"
del /f /q server.zip
cd server
7z a -y "..\server.zip" .
cd ..
rd /s /q server
pause
exit
