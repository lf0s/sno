@echo off
setlocal EnableDelayedExpansion
title sno (simple network optimizer)
color 0b

echo.
echo             sno
echo answer y/n to apply each step
echo      github.com/lf0s/sno
echo.

:dnsflush
set /p df="flush and reset dns cache (y/n): "
if /i "!df!"=="y" (
    ipconfig /flushdns >nul 2>&1
    if !errorlevel!==0 echo dns cache flushed
) else if /i "!df!"=="n" (
    echo skipping
) else goto dnsflush

:dnsservers
set /p ds="set public dns servers (y/n): "
if /i "!ds!"=="y" (
    for /f "tokens=3*" %%a in ('netsh interface show interface ^| findstr "Connected"') do (
        netsh interface ip set dns name="%%b" static 1.1.1.1 primary >nul 2>&1
        netsh interface ip add dns name="%%b" 8.8.8.8 index=2 >nul 2>&1
    )
    echo public dns servers set
) else if /i "!ds!"=="n" (
    echo skipping
) else goto dnsservers

:dnscache
set /p dc="clear dns client cache files (y/n): "
if /i "!dc!"=="y" (
    net stop dnscache >nul 2>&1
    del /q /f %windir%\System32\dns\*.* >nul 2>&1
    net start dnscache >nul 2>&1
    echo dns client cache cleared
) else if /i "!dc!"=="n" (
    echo skipping
) else goto dnscache

:releaseip
set /p ri="release and renew ip (y/n): "
if /i "!ri!"=="y" (
    ipconfig /release >nul 2>&1
    ipconfig /renew >nul 2>&1
    echo ip released and renewed
) else if /i "!ri!"=="n" (
    echo skipping
) else goto releaseip

:resetnetwork
set /p rn="reset network stack (y/n): "
if /i "!rn!"=="y" (
    netsh winsock reset >nul 2>&1
    netsh int ip reset >nul 2>&1
    echo network stack reset
) else if /i "!rn!"=="n" (
    echo skipping
) else goto resetnetwork

:resettcp
set /p rt="reset tcp parameters (y/n): "
if /i "!rt!"=="y" (
    netsh int tcp reset >nul 2>&1
    echo tcp parameters reset
) else if /i "!rt!"=="n" (
    echo skipping
) else goto resettcp

:tcpauto
set /p ta="enable tcp auto-tuning (y/n): "
if /i "!ta!"=="y" (
    netsh int tcp set global autotuninglevel=normal >nul 2>&1
    echo tcp auto-tuning enabled
) else if /i "!ta!"=="n" (
    echo skipping
) else goto tcpauto

:ipv6tunnels
set /p it="disable old ipv6 tunnels (y/n): "
if /i "!it!"=="y" (
    netsh interface teredo set state disabled >nul 2>&1
    netsh interface 6to4 set state disabled >nul 2>&1
    netsh interface isatap set state disabled >nul 2>&1
    echo ipv6 tunnels disabled
) else if /i "!it!"=="n" (
    echo skipping
) else goto ipv6tunnels

:netshopt
set /p no="optimize netsh parameters for latency (y/n): "
if /i "!no!"=="y" (
    netsh int tcp set global chimney=enabled >nul 2>&1
    netsh int tcp set global rss=enabled >nul 2>&1
    netsh int tcp set global netdma=enabled >nul 2>&1
    echo netsh parameters optimized
) else if /i "!no!"=="n" (
    echo skipping
) else goto netshopt

:arp
set /p ac="clear arp cache (y/n): "
if /i "!ac!"=="y" (
    arp -d * >nul 2>&1
    echo arp cache cleared
) else if /i "!ac!"=="n" (
    echo skipping
) else goto arp

:tempfiles
set /p tf="clear temp internet files (y/n): "
if /i "!tf!"=="y" (
    RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8 >nul 2>&1
    del /q /f /s %temp%\*.* >nul 2>&1
    echo temp files cleared
) else if /i "!tf!"=="n" (
    echo skipping
) else goto tempfiles

:pingtest
set /p pt="run ping test to 1.1.1.1 (y/n): "
if /i "!pt!"=="y" (
    ping -n 4 1.1.1.1
) else if /i "!pt!"=="n" (
    echo skipping
) else goto pingtest

:speedtest
set /p st="run a really simple speedtest (y/n): "
if /i "!st!"=="y" (
    echo testing speed...
    powershell -Command "$dl = (Measure-Command {try{$null = Invoke-WebRequest 'http://www.google.com' -TimeoutSec 5}catch{}}).TotalMilliseconds; $ul = (Measure-Command {try{$null = Invoke-RestMethod 'https://httpbin.org/post' -Method Post -Body 'test' -TimeoutSec 5}catch{}}).TotalMilliseconds; Write-Host 'ping:' ([math]::Round($dl/4)) 'ms'; Write-Host 'response:' ([math]::Round($ul/2)) 'ms'" 2>nul
) else if /i "!st!"=="n" (
    echo skipping
) else goto speedtest

echo.
echo done. restart may be needed.
pause