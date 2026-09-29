@echo off
rem 双击运行：新建一个标准项目目录
setlocal
set /p NAME=请输入项目名（如 桥梁监测）： 
if "%NAME%"=="" (
  echo 项目名不能为空。
  pause
  exit /b 1
)
bash "%~dp0新建项目.sh" "%NAME%"
pause
