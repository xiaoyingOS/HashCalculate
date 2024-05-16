@echo off
# 设置 CMD 窗口字符编码为 UTF-8
chcp 65001 > nul
powershell.exe -ExecutionPolicy Bypass -File "%~dp0.\00_Hash.ps1"