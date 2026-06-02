@echo off
echo ========================================
echo  Monster Mash Simulator - Quick Setup
echo ========================================
echo.

echo Step 1: Installing Rojo plugin in Roblox Studio...
echo.
echo   1. Open Roblox Studio
echo   2. Go to Plugins tab -^> Manage Plugins
echo   3. Click "Load from File"
echo   4. Select the file "Rojo.rbxm"
echo.
pause
echo.

echo Step 2: Starting Rojo server...
"%~dp0rojo.exe" serve
pause