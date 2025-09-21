@echo off
setlocal EnableDelayedExpansion
title sno (simple network optimizer)
color 0b

echo.
echo            sno 0.2
echo answer y/n to apply each step
echo      github.com/lf0s/sno
echo.

REM ==============================
REM DNS & Network Cleanup
REM ==============================
:dnsflush
set /p df="flush and reset dns cache (y/n): "
if /i "!df!"=="y" (
    ipconfig /flushdns >nul 2>&1
    echo dns cache flushed
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

:nbt
set /p nb="clear NetBIOS cache (y/n): "
if /i "!nb!"=="y" (
    nbtstat -R >nul 2>&1
    nbtstat -RR >nul 2>&1
    echo NetBIOS cache cleared
) else if /i "!nb!"=="n" (
    echo skipping
) else goto nbt

:tempfiles
set /p tf="clear temp internet files (y/n): "
if /i "!tf!"=="y" (
    RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8 >nul 2>&1
    del /q /f /s %temp%\*.* >nul 2>&1
    echo temp files cleared
) else if /i "!tf!"=="n" (
    echo skipping
) else goto tempfiles

REM ==============================
REM Diagnostics
REM ==============================
:winsockdiag
set /p wd="show winsock catalog diagnostics (y/n): "
if /i "!wd!"=="y" (
    netsh winsock show catalog
) else if /i "!wd!"=="n" (
    echo skipping
) else goto winsockdiag

:netstat
set /p ns="show active connections (y/n): "
if /i "!ns!"=="y" (
    netstat -ano
) else if /i "!ns!"=="n" (
    echo skipping
) else goto netstat

:tracert
set /p tr="trace route to 1.1.1.1 (y/n): "
if /i "!tr!"=="y" (
    tracert 1.1.1.1
) else if /i "!tr!"=="n" (
    echo skipping
) else goto tracert

:hostsclear
set /p hc="reset hosts file (y/n): "
if /i "!hc!"=="y" (
    copy /y %windir%\System32\drivers\etc\hosts %windir%\System32\drivers\etc\hosts.bak >nul 2>&1
    echo # Default Windows hosts file > %windir%\System32\drivers\etc\hosts
    echo hosts file reset (backup saved)
) else if /i "!hc!"=="n" (
    echo skipping
) else goto hostsclear

:winsocklog
set /p wl="enable winsock logging (y/n): "
if /i "!wl!"=="y" (
    netsh trace start capture=yes persistent=no maxsize=20M tracefile=%userprofile%\Desktop\winsock.etl >nul 2>&1
    timeout /t 5 >nul
    netsh trace stop >nul 2>&1
    echo winsock log saved to Desktop
) else if /i "!wl!"=="n" (
    echo skipping
) else goto winsocklog

:firewallreset
set /p fr="reset windows firewall (y/n): "
if /i "!fr!"=="y" (
    netsh advfirewall reset >nul 2>&1
    echo windows firewall reset
) else if /i "!fr!"=="n" (
    echo skipping
) else goto firewallreset

:ipdisplay
set /p id="show detailed ipconfig (y/n): "
if /i "!id!"=="y" (
    ipconfig /all
) else if /i "!id!"=="n" (
    echo skipping
) else goto ipdisplay

:systemdns
set /p sd="flush local system resolver cache (y/n): "
if /i "!sd!"=="y" (
    PowerShell Clear-DnsClientCache
    echo system dns client cache flushed
) else if /i "!sd!"=="n" (
    echo skipping
) else goto systemdns

:wifiprofiles
set /p wp="show saved wifi profiles (y/n): "
if /i "!wp!"=="y" (
    netsh wlan show profiles
) else if /i "!wp!"=="n" (
    echo skipping
) else goto wifiprofiles

:wifireset
set /p wr="reset wireless adapter (y/n): "
if /i "!wr!"=="y" (
    for /f "tokens=1,2*" %%a in ('netsh interface show interface ^| findstr "Wi-Fi"') do (
        netsh interface set interface name="%%c" admin=disable >nul 2>&1
        timeout /t 3 >nul
        netsh interface set interface name="%%c" admin=enable >nul 2>&1
    )
    echo wireless adapter reset
) else if /i "!wr!"=="n" (
    echo skipping
) else goto wifireset

:routetable
set /p rtb="show routing table (y/n): "
if /i "!rtb!"=="y" (
    route print
) else if /i "!rtb!"=="n" (
    echo skipping
) else goto routetable

:adapterstatus
set /p ad="show network adapter status (y/n): "
if /i "!ad!"=="y" (
    netsh interface show interface
) else if /i "!ad!"=="n" (
    echo skipping
) else goto adapterstatus

:pingtest
set /p pt="run ping test to multiple endpoints (y/n): "
if /i "!pt!"=="y" (
    ping -n 4 1.1.1.1
    ping -n 4 8.8.8.8
    ping -n 4 google.com
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
