cd /d "%~dp0"
7z x "client.zip" -o"client" -y -xr!"vehicles" -xr!"effects\vehicles"
del /f /q client.zip
cd client
7z a -y "..\client.zip" .
cd ..
rd /s /q client
pause
exit
