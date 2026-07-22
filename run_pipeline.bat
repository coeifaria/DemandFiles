@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo   DemandFiles Automated Pipeline
echo ===================================================

REM 1. Locate Rscript executable
set "RSCRIPT=C:\Users\if001\AppData\Local\Programs\R\R-4.5.1\bin\Rscript.exe"

if not exist "!RSCRIPT!" (
    where Rscript >nul 2>&1
    if !errorlevel! equ 0 (
        set "RSCRIPT=Rscript"
    ) else (
        echo [ERROR] Could not find Rscript.exe.
        echo Please verify R installation at C:\Users\if001\AppData\Local\Programs\R\R-4.5.1\bin\
        pause
        exit /b 1
    )
)

echo Using Rscript: "!RSCRIPT!"

REM 2. Check if data folder has Excel files
dir /b "data\*.xlsx" >nul 2>&1
if !errorlevel! neq 0 (
    echo [WARNING] No .xlsx files found in 'data/' folder.
    echo Please place raw Lightcast Excel files in 'data/' and re-run this script.
    pause
    exit /b 1
)

echo.
echo [1/3] Processing raw Excel files with R...
"!RSCRIPT!" xlsx_to_rds.R
if !errorlevel! neq 0 (
    echo [ERROR] R script failed to execute. Check error messages above.
    pause
    exit /b 1
)

echo.
echo [2/3] Staging generated RDS files and archived data folders...
git add demand_files_*.rds data_* data/.gitkeep README.md Agents.md

echo.
echo [3/3] Git Status Summary:
git status --short

echo.
set "COMMIT_MSG=feat: update demand files and raw data archive"
set "USER_MSG="
set /p "USER_MSG=Enter commit message (or press Enter for default): "
if defined USER_MSG set "COMMIT_MSG=!USER_MSG!"

git diff --cached --quiet
if !errorlevel! equ 0 goto NO_CHANGES

echo.
echo Committing changes with message: "!COMMIT_MSG!"
git commit -m "!COMMIT_MSG!"

echo.
echo Pushing to GitHub (GithubRepo master)...
git push GithubRepo master
goto DONE

:NO_CHANGES
echo No new staged changes to commit.

:DONE
echo.
echo ===================================================
echo   Pipeline completed successfully!
echo ===================================================
pause
