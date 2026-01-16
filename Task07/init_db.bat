@echo off
chcp 65001 >nul

echo Initializing database...

sqlite3 students.db < db_init.sql

if %ERRORLEVEL% EQU 0 (
    echo Database initialized successfully!
) else (
    echo Error initializing database!
    exit /b 1
)

