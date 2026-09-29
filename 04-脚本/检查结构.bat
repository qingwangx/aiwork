@echo off
rem 双击运行：检查 F:\AIwork 目录结构
rem 自动补齐缺失目录：命令行执行  检查结构.bat --fix
setlocal
bash "%~dp0检查结构.sh" %*
echo.
pause
