@echo off
rem ============================================================
rem Double-click to check the workspace structure.
rem From a command line, pass --fix to auto-repair missing dirs.
rem
rem Pure ASCII on purpose, comments included -- see the note in
rem the new-project launcher for why.
rem ============================================================
setlocal
bash "%~dp0check-structure.sh" %*
chcp 936 >nul
echo.
pause
