@echo off
echo ========================================
echo  Monster Mash - ONE CLICK SETUP
echo ========================================
echo.

:: Check if rojo.exe exists, if not download it
if not exist "rojo.exe" (
    echo Downloading Rojo v7.6.1...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/rojo-rbx/rojo/releases/download/v7.6.1/rojo-7.6.1-windows-x86_64.zip' -OutFile 'rojo-temp.zip'"
    powershell -Command "Expand-Archive -Force 'rojo-temp.zip' '.'"
    del rojo-temp.zip
    echo Done!
)

:: Install the Rojo plugin in Studio
echo.
echo Step 1: Install Rojo plugin in Roblox Studio
echo   1. Open Roblox Studio
echo   2. Plugins tab -^> Manage Plugins
echo   3. Click "Load from File" -^> select Rojo.rbxm
echo.
pause

:: Start Rojo server
echo.
echo Step 2: Starting Rojo server...
start "" "rojo.exe" serve
echo.
echo Now go to Roblox Studio -^> Rojo tab -^> Connect!
echo The game will sync automatically.
echo.
pause