@echo off
chcp 65001 >nul
title Project Tree Analyzer - Чистая сборка релиза
color 0B

echo ========================================
echo   АНАЛИЗАТОР СТРУКТУРЫ ПРОЕКТА
echo   Чистая сборка финальной версии
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

:: Переход в папку src-tauri для корректной работы cargo clean
cd src-tauri

echo [INFO] Очистка артефактов предыдущих сборок...
cargo clean
if %errorlevel% neq 0 (
    echo [ПРЕДУПРЕЖДЕНИЕ] Не удалось выполнить cargo clean, продолжаем сборку...
) else (
    echo [OK] Папка target успешно очищена.
)

echo.
echo [INFO] Начало компиляции оптимизированной версии...
echo [INFO] Это может занять несколько минут.
echo.

:: Запуск сборки
cargo tauri build

:: Возврат в корень проекта
cd ..

:: Обработка результата
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   СБОРКА УСПЕШНО ЗАВЕРШЕНА
    echo ========================================
    echo.
    echo Исполняемый файл находится здесь:
    echo src-tauri\target\release\project-tree-analyzer.exe
    echo.
    echo Установщик (MSI/NSIS):
    echo src-tauri\target\release\bundle\
    echo.
) else (
    echo.
    echo [ОШИБКА] Сборка завершилась с кодом ошибки: %errorlevel%
    echo Проверьте логи выше для выявления причин сбоя.
)

pause