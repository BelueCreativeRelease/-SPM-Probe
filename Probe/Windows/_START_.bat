@echo off

REM 2021.04.27
set SPM_Probe_Version=SPM Probe:2021.04.27

REM Files
REM get_reg_hklm_ver.ps1, get_systeminfo.ps1, app_scan.ps1, scan_jar.ps1, Write-allkb-ttls.ps1
REM get_NET_Framework_ver.ps1
REM get_programinfo.ps1, process.ps1, winsv_checker.bat
REM makezip.vbs

REM Domain Check for MS14-025 KB2928120 KB2961899 MS15-011 KB3000483

REM 2020.05.27
REM Error log 

REM 2020．05.11
REM winsv_checker.bat 追加

REM 2021.04.27
REM get_programinfo.ps1 追加

for /f "usebackq" %%a in (`powershell -Command " & { ( Get-UICulture).Name } "`) do @set langstr=%%a
for /f "usebackq tokens=*" %%a in (`powershell -Command Get-Date -Format "yyyyMMdd"`) do @set datestr=%%a
for /f "usebackq tokens=*" %%a in (`powershell -Command Get-Date -Format "HHmm"`) do @set timestr=%%a

REM

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackageIndex" /f * /k /reg:64 > nul 2> nul
if %ERRORLEVEL% EQU 0 goto normal
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\ApplicabilityEvaluationCache" /f * /k /reg:64 > nul 2> nul
if %ERRORLEVEL% EQU 0 goto normal
	rem Registry Error
	echo レジストリエラー: システムを再起動後、再実行願います。
	goto err

:normal

if "%1" NEQ "" goto exsitarg
rem	echo 引数なし
	set OUTSTR=SPMWindows_Probe_%datestr%-%timestr%
	echo Folder name : %OUTSTR%
	goto argchk_e
:exsitarg
	set OUTSTR=%1
	echo Folder name : %OUTSTR%
	echo file name : %OUTSTR%.txt, %OUTSTR%.csv, %OUTSTR%.WindowsUpdate.log

:argchk_e
@echo off

rem OUTSTR=SPMWindows_Probe_%datestr%-%timestr%
set ERROUT=%OUTSTR%.errorlog.txt

md %OUTSTR%

rem
@echo Start: >%OUTSTR%\%ERROUT%
@echo File Name: %OUTSTR% >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
@echo date-time >>%OUTSTR%\%ERROUT%
date /t >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
time /t >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

echo; >>%OUTSTR%\%OUTSTR%.txt
echo %SPM_Probe_Version% >>%OUTSTR%\%OUTSTR%.txt

echo; >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo ver: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
ver >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

echo reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" >>%OUTSTR%\%ERROUT%
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /f PROCESSOR_ARCHITECTURE /reg:64 >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%


echo powershell .\get_reg_hklm_ver.ps1 >>%OUTSTR%\%ERROUT%
REM with ProductId
REM reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /f * /d /t REG_SZ /reg:64 >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
rem ProductId: -> remove
powershell  -NoProfile -ExecutionPolicy Unrestricted -Command "& { .\get_reg_hklm_ver.ps1 } " >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo. >>%OUTSTR%\%OUTSTR%.txt

echo reg query "HKLM\SOFTWARE\Microsoft" >>%OUTSTR%\%OUTSTR%.txt >>%OUTSTR%\%ERROUT%
echo :HKLM\SOFTWARE\Microsoft\Internet Explorer START: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
reg query "HKLM\SOFTWARE\Microsoft\Internet Explorer" /f * /d /reg:64 >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo :HKLM\SOFTWARE\Microsoft\Internet Explorer END: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

echo. >>%OUTSTR%\%OUTSTR%.txt
echo :ComponentDetect: >>%OUTSTR%\%ERROUT%
echo :ComponentDetect START: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\ComponentDetect" /f * /k /reg:64 >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackageDetect" /f * /k /reg:64 >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo :ComponentDetect END: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

echo. >>%OUTSTR%\%OUTSTR%.txt
echo :PackageIndex: >>%OUTSTR%\%ERROUT%
echo :PackageIndex START: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackageIndex" /f * /k /reg:64 >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages" /f * /k /reg:64 >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo :PackageIndex END: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

echo. >>%OUTSTR%\%ERROUT%
echo. >>%OUTSTR%\%OUTSTR%.txt

echo :ApplicabilityEvaluationCache: >>%OUTSTR%\%ERROUT%
echo :ApplicabilityEvaluationCache START: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\ApplicabilityEvaluationCache" /f * /k /reg:64 >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo :ApplicabilityEvaluationCache END: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

rem All KB Titles 
echo: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo All KB Titles: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo powershell  -NoProfile -ExecutionPolicy Unrestricted -Command "& { .\Write-allkb-ttls.ps1 } " >>%OUTSTR%\%ERROUT%
powershell  -NoProfile -ExecutionPolicy Unrestricted -Command "& { .\Write-allkb-ttls.ps1 } " >>%OUTSTR%\%OUTSTR%.AllKBTitles.txt 2>>%OUTSTR%\%ERROUT%
echo: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

rem Check Domain / Workgroup
echo: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo IsDomain: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
powershell  -NoProfile -ExecutionPolicy Unrestricted -Command "& { ( Get-wmiObject Win32_ComputerSystem ).PartOfDomain }"  >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%
echo: >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

rem systeminfo >>%OUTSTR%\%OUTSTR%.txt 2>>&1
rem プロダクト ID: -> remove
echo powershell  -NoProfile -ExecutionPolicy Unrestricted -Command "& { .\get_systeminfo.ps1 } " >>%OUTSTR%\%ERROUT%
powershell  -NoProfile -ExecutionPolicy Unrestricted -Command "& { .\get_systeminfo.ps1 } " >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

rem 
echo ----- File Check ----- >>%OUTSTR%\%OUTSTR%.txt 2>>&1

rem gppref.dll
echo "Check gppref.dll" >>%OUTSTR%\%OUTSTR%.txt 2>>&1
echo powershell Get-Item C:\Windows\System32\gppref.dll >>%OUTSTR%\%ERROUT%
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { Get-Item C:\Windows\System32\gppref.dll | Select-Object * } "  >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

rem Iscsitgt.dll
echo "Check Iscsitgt.dll" >>%OUTSTR%\%OUTSTR%.txt 2>>&1
echo powershell Get-Item C:\Windows\System32\Iscsitgt.dll >>%OUTSTR%\%ERROUT%
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { Get-Item C:\Windows\System32\Iscsitgt.dll | Select-Object * } "  >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%


rem Microsoft.Update.Session から履歴を取得

echo powershell $Session = New-Object -ComObject Microsoft.Update.Session >>%OUTSTR%\%ERROUT%
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { $Session = New-Object -ComObject Microsoft.Update.Session ; $Searcher = $Session.CreateUpdateSearcher() ; $HistoryCount = $Searcher.GetTotalHistoryCount() ; $Searcher.QueryHistory(1,$HistoryCount) | Export-Csv -Encoding Default -Path %OUTSTR%\%OUTSTR%.csv }" 2>>%OUTSTR%\%ERROUT%


rem
echo "copy WindowsUpdate.log "  >>%OUTSTR%\%OUTSTR%.txt

echo copy %WINDIR%\WindowsUpdate.log %OUTSTR%\%OUTSTR%.WindowsUpdate.log >>%OUTSTR%\%ERROUT%
echo copy %WINDIR%\WindowsUpdate.log %OUTSTR%\%OUTSTR%.WindowsUpdate.log >>%OUTSTR%\%OUTSTR%.txt
copy %WINDIR%\WindowsUpdate.log %OUTSTR%\%OUTSTR%.WindowsUpdate.log >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

rem Windows Update の履歴 ReportingEvents.log を取得
echo copy %WINDIR%\SoftwareDistribution\ReportingEvents.log %OUTSTR%\%OUTSTR%.ReportingEvents.log >>%OUTSTR%\%ERROUT%
echo copy %WINDIR%\SoftwareDisttiontion\ReportingEvents.log %OUTSTR%\%OUTSTR%.ReportingEvents.log >>%OUTSTR%\%OUTSTR%.txt
copy %WINDIR%\SoftwareDistribution\ReportingEvents.log %OUTSTR%\%OUTSTR%.ReportingEvents.log >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%


rem
echo appscan: >>%OUTSTR%\%ERROUT%
echo "appscan:" >>%OUTSTR%\%OUTSTR%.txt
echo powershell app_scan.ps1 >>%OUTSTR%\%ERROUT%
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { .\app_scan.ps1 %OUTSTR%\%OUTSTR% } " >>%OUTSTR%\%OUTSTR%.txt 2>>%OUTSTR%\%ERROUT%

rem
rem .NET Framework version
rem
echo .NET Framework Versions >>%OUTSTR%\%ERROUT%
echo .NET Framework Versions >>%OUTSTR%\%OUTSTR%.Components.txt 2>>%OUTSTR%\%ERROUT%
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { .\get_NET_Framework_ver.ps1 } "  >>%OUTSTR%\%OUTSTR%.Components.txt 2>>&1
rem  コンポーネント情報を追加する場合は上記処理に倣って .Components.txt ファイルに追加する

rem Scan jar
echo powershell scan_jar.ps1 >>%OUTSTR%\%ERROUT%
rem echo Scan *.jar >>%OUTSTR%\%OUTSTR%.scan_jar.txt 2>>&1
rem powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { Get-WmiObject Win32_LogicalDisk | Where-Object -filterScript { $_.DriveType -ne 5 } | ForEach-Object -Process{ echo $_.Name ; echo 'Scan: *.jar' ;where.exe /R $_.Name '*.jar' } }" >>%OUTSTR%\%OUTSTR%.scan_jar.txt 2>>&1
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { .\scan_jar.ps1 } "  >>%OUTSTR%\%OUTSTR%.scan_jar.txt 2>>%OUTSTR%\%ERROUT%

rem winsv_checker.bat
echo call winsv_checker.bat >>%OUTSTR%\%ERROUT%
call winsv_checker.bat %OUTSTR% >> %OUTSTR%\%OUTSTR%.winsv_checker_log.txt 2>>%OUTSTR%\%ERROUT%
echo ret  winsv_checker.bat >>%OUTSTR%\%ERROUT%

@echo End: >>%OUTSTR%\%OUTSTR%.txt
@echo End: >>%OUTSTR%\%ERROUT%

rem Make ZIP 
echo Make ZIP >>%OUTSTR%\%ERROUT%
wscript //B makezip.vbs %OUTSTR%.zip %OUTSTR%

if %langstr%==en-US goto finish

echo 正常に終了しました。
echo 出力ファイル:c ..\%OUTSTR%.zip
goto end-move

:finish
rem English message
echo Finished normally.
echo Output File: ..\%OUTSTR%.zip

:end-move

rem Move Result
move %OUTSTR% ..\ > nul
move %OUTSTR%.zip ..\ > nul

goto end

:err
if %langstr%==en-US goto err-en
echo エラーで終了しました。
goto end

:err-en
echo Error finish

:end
pause
