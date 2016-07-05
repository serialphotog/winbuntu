:: Winbuntu - The Ubuntu Linux Environment for Windows 10
:: An awesome Linux environment that runs using WSL on Windows 10
::
:: Author: Adam Thompson <adam@serialphotog.com>

@echo off

:: Get the path of our Winbuntu install
FOR /F "usebackq tokens=2,* skip=2" %%L IN (
    `reg query "HKLM\SOFTWARE\winbuntu" /v WinbuntuPath`
) DO SET installPath=%%M

start %installPath%"\bin\XWin.exe" -listen tcp
start "" "bash" "environment.sh"