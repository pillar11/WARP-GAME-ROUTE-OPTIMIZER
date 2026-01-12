@echo off
setlocal ENABLEDELAYEDEXPANSION

:: ================================
:: GAME MENU
:: ================================
:MENU
cls
color 0F
set "IP_LIST="
echo ==================================================
echo             WARP GAME ROUTE OPTIMIZER - Pillar.1
echo ==================================================
:: --- ADMIN CHECK WITH RED TEXT ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Write-Host '[!] WARNING: NOT RUNNING AS ADMINISTRATOR' -ForegroundColor Red"
    powershell -Command "Write-Host '    Optimization may fail to trigger warp-cli.' -ForegroundColor Red"
    echo --------------------------------------------------
)

:: --- ORANGE REMINDER TEXT ---
powershell -Command "Write-Host '[!] REMINDER: YOU NEED TO SWITCH TO 1.1.1.1 WITH WARP IN APP' -ForegroundColor Yellow"
echo --------------------------------------------------

echo 1. Rainbow Six Siege
echo 2. Battlefield
echo 3. Warzone
echo 4. CS2
echo 5. Valorant
echo 6. Fortnite
echo 7. Apex Legends
echo 8. League of Legends
echo 9. Global
echo --------------------------------------------------
set /p choice="Select a number (1-9): "

if "%choice%"=="1" set "IP_LIST=35.71.111.128 35.71.98.100" & set "GNAME=R6S"
if "%choice%"=="2" set "IP_LIST=35.71.105.128 35.71.120.129 35.71.74.116 35.71.98.100" & set "GNAME=Battlefield"
if "%choice%"=="3" set "IP_LIST=35.71.105.128 35.71.74.116" & set "GNAME=Warzone"
if "%choice%"=="4" set "IP_LIST=35.71.105.14 35.71.111.100" & set "GNAME=CS2"
if "%choice%"=="5" set "IP_LIST=35.71.98.102 35.71.111.100 35.71.105.14" & set "GNAME=Valorant"
if "%choice%"=="6" set "IP_LIST=35.71.105.14" & set "GNAME=Fortnite"
if "%choice%"=="7" set "IP_LIST=35.71.111.128 35.71.105.14" & set "GNAME=Apex Legends"
if "%choice%"=="8" set "IP_LIST=35.71.105.107 52.94.15.82" & set "GNAME=LoL"
if "%choice%"=="9" set "IP_LIST=8.8.8.8" & set "GNAME=Global"

if not defined IP_LIST echo Invalid choice! & timeout /t 2 >nul & goto MENU

:: ================================
:: CONFIG
:: ================================
set PING_COUNT=4
set WAIT_SECONDS=5
set MAX_ATTEMPTS=20

title Optimizer: %GNAME%
cls
echo ==================================================
echo  Pillar.1   -   OPTIMIZING FOR: %GNAME%
echo ==================================================

:: === BASELINE SEARCH (WARP OFF) ===
color 0E
echo [!] Disconnecting WARP for baseline test...
warp-cli disconnect >nul 2>&1
timeout /t 3 >nul

echo [!] Scanning regions to find individual baselines...

for %%I in (%IP_LIST%) do (
    set "RNAME=%%I"
    if "%%I"=="35.71.111.128" set "RNAME=EU West"
    if "%%I"=="35.71.98.100"  set "RNAME=EU North"
    if "%%I"=="35.71.105.128" set "RNAME=EU Central"
    if "%%I"=="35.71.120.129" set "RNAME=EU South"
    if "%%I"=="35.71.74.116"  set "RNAME=EU West"
    if "%%I"=="35.71.105.14"  set "RNAME=EU Central"
    if "%%I"=="35.71.111.100" set "RNAME=EU West"
    if "%%I"=="35.71.98.102"  set "RNAME=EU North"
    if "%%I"=="35.71.105.107" set "RNAME=EU Central"
    if "%%I"=="52.94.15.82"   set "RNAME=EU West"
    if "%%I"=="8.8.8.8"       set "RNAME=Global"

    set "TEMP_TOTAL=0"
    set "TEMP_COUNT=0"
    for /f "delims=" %%L in ('ping -n 2 %%I ^| find "time="') do (
        set "line=%%L"
        set "line=!line:*time=!"
        set "line=!line:~1!"
        for /f "delims=m " %%A in ("!line!") do (
            set "val=%%A"
            set "val=!val: =!"
            set /a TEMP_TOTAL+=!val!
            set /a TEMP_COUNT+=1
        )
    )
    if !TEMP_COUNT! GTR 0 (
        set /a AVG=TEMP_TOTAL/TEMP_COUNT
        :: Save baseline specifically for this IP
        set "BASE_%%I=!AVG!"
        echo            - !RNAME!: !AVG! ms
    ) else (
        set "BASE_%%I=999"
    )
)

echo --------------------------------------------------

:: === OPTIMIZATION LOOP ===
set ATTEMPT=0
:LOOP
set /a ATTEMPT+=1

if %ATTEMPT% GTR %MAX_ATTEMPTS% (
    color 4F
    echo.
    echo ==================================================
    echo    LIMIT REACHED: %MAX_ATTEMPTS% attempts completed.
    echo    Try again.
    echo ==================================================
    warp-cli disconnect >nul 2>&1
    pause
    goto MENU
)

color 0E
echo.
echo [Attempt #%ATTEMPT%/%MAX_ATTEMPTS%] Hunting for better routes... (Press 'M' for Menu)
warp-cli connect >nul 2>&1

choice /C M0 /T %WAIT_SECONDS% /D 0 /N >nul
if errorlevel 2 (
    rem Proceed
) else (
    goto MENU
)

:: Test ALL regions in the list
for %%G in (%IP_LIST%) do (
    set "CURRENT_RNAME=%%G"
    if "%%G"=="35.71.111.128" set "CURRENT_RNAME=EU West"
    if "%%G"=="35.71.98.100"  set "CURRENT_RNAME=EU North"
    if "%%G"=="35.71.105.128" set "CURRENT_RNAME=EU Central"
    if "%%G"=="35.71.120.129" set "CURRENT_RNAME=EU South"
    if "%%G"=="35.71.74.116"  set "CURRENT_RNAME=EU West"
    if "%%G"=="35.71.105.14"  set "CURRENT_RNAME=EU Central"
    if "%%G"=="35.71.111.100" set "CURRENT_RNAME=EU West"
    if "%%G"=="35.71.98.102"  set "CURRENT_RNAME=EU North"
    if "%%G"=="35.71.105.107" set "CURRENT_RNAME=EU Central"
    if "%%G"=="52.94.15.82"   set "CURRENT_RNAME=EU West"
    if "%%G"=="8.8.8.8"       set "CURRENT_RNAME=Global"

    set TOTAL=0
    set COUNT=0
    for /f "delims=" %%L in ('ping -n %PING_COUNT% %%G ^| find "time="') do (
        set "line=%%L"
        set "line=!line:*time=!"
        set "line=!line:~1!"
        for /f "delims=m " %%A in ("!line!") do (
            set "val=%%A"
            set "val=!val: =!"
            set /a TOTAL+=!val!
            set /a COUNT+=1
        )
    )

    if !COUNT! GTR 0 (
        set /a CURRENT=TOTAL/COUNT
        :: Pull the specific baseline for this IP
        set "THIS_BASELINE=!BASE_%%G!"
        
        echo [^>] !CURRENT_RNAME!: !CURRENT! ms (Goal: Under !THIS_BASELINE! ms)
        
        if !CURRENT! LSS !THIS_BASELINE! (
            set "WINNING_RNAME=!CURRENT_RNAME!"
            set "WINNING_BASE=!THIS_BASELINE!"
            set "WINNING_PING=!CURRENT!"
            goto SUCCESS
        )
    )
)

color 4F
echo [x] No optimal routes found this attempt.

:RETRY
warp-cli disconnect >nul 2>&1
choice /C M0 /T 2 /D 0 /N >nul
if errorlevel 2 (
    goto LOOP
) else (
    goto MENU
)

:SUCCESS
color 2F
echo.
echo **************************************************
echo       SUCCESS: OPTIMAL ROUTE SECURED! - Pillar.1
echo **************************************************
echo             Game      : %GNAME%
echo             Region    : !WINNING_RNAME!
echo             Baseline  : !WINNING_BASE! ms
echo             Optimized : !WINNING_PING! ms
echo **************************************************
echo Press any key to return to Game Selection...
pause >nul
goto MENU