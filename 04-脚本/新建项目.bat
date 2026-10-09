@echo off
rem ============================================================
rem Double-click to scaffold a new project (01-xiangmu\<name>).
rem
rem THIS FILE MUST STAY PURE ASCII -- not even in comments.
rem cmd.exe parses .bat content using the console codepage (GBK),
rem and the chcp below shifts cmd's parse offset: any non-ASCII
rem byte here then gets mis-parsed as a bogus command. Verified
rem twice (errors: "'?' is not recognized", "'m' is not recognized").
rem All Chinese user-facing text lives in new-project.sh instead.
rem ============================================================
setlocal
bash "%~dp0new-project.sh"
chcp 936 >nul
echo.
pause
