@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo   DemandFiles Automated Pipeline
echo ===================================================

:: Check if Rscript is available in PATH
where Rscript >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Rscript was not found in PATH.
    echo Please install R or ensure Rscript is added to your environment variables.
    pause
    exit /b 1
)

:: Check if data folder has Excel files
dir /b "data\*.xlsx" >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] No .xlsx files found in 'data/' folder.
    echo Please place raw Lightcast Excel files in 'data/' and re-run this script.
    pause
    exit /b 1
)

echo.
echo [1/3] Processing raw Excel files with R...
Rscript xlsx_to_rds.R

if %errorlevel% neq 0 (
    echo [ERROR] R script failed to execute.
    pause
    exit /b 1
)

echo.
echo [2/3] Staging generated RDS files and archived data folders...
git add demand_files_*.rds data_* data/.gitkeep

echo.
echo [3/3] Git Status Summary:
git status --short

echo.
set /p COMMIT_MSG="Enter commit message (or press Enter for default): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=feat: update demand files and raw data archive

git commit -m "%COMMIT_MSG%"
echo Pushing to GitHub (GithubRepo master)...
git push GithubRepo master

echo.
echo ===================================================
echo   Pipeline completed successfully!
echo ===================================================
pause
