@echo off
chcp 65001 >nul
title Project Tree Analyzer - Режим разработки
color 0A

echo ========================================
echo   АНАЛИЗАТОР СТРУКТУРЫ ПРОЕКТА
echo   Режим разработки (Hot Reload)
echo ========================================
echo.

:: Проверка наличия Cargo Tauri
where cargo-tauri >nul 2>nul
if %errorlevel% neq 0 (
    echo [ОШИБКА] cargo-tauri не найден в системе.
    echo Установите его командой: cargo install tauri-cli --version "^1.6.6"
    echo.
    pause
    exit /b 1
)

echo [INFO] Запуск сервера разработки...
echo [INFO] Для остановки нажмите Ctrl+C
echo.

:: Запуск Tauri в режиме разработки
cargo tauri dev

:: Если команда завершилась с ошибкой
if %errorlevel% neq 0 (
    echo.
    echo [ОШИБКА] Процесс завершен с кодом ошибки: %errorlevel%
    pause
)