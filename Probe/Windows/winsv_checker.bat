@echo off

REM winsv_checker 出力フォルダ名
REM 

REM 変更経歴
REM 2021.03.01 Ver. 1.2a 引数を1つに変更、エラーログファイルは出力フォルダ配下になるため
REM 2021.01.19 Ver. 1.2 出力フォルダが存在している場合の処理を追加
REM 2020.05.27 Ver. 1.1 Error 出力を1ファイルに
REM 2020.05.11 Ver. 1.0
REM 2020.05.11 出力ファイル名の変更 コンピュータ名 を削除、第1引数文字列を先頭に付与
REM 2021.04.27 インストール済みファイル一覧取得処理をget_programinfo.ps1で行うように修正

REM 20/02/26 コメント書きの視認性のため「%date%」「%time%」間に空白を挿入
REM 20/02/26 コマンド「net user」後に、空白のあるユーザアカウント対応のため「^"」を挿入
REM 20/03/02 要件①引数判定にてログ格納フォルダ作成機構を追加
REM 20/03/02 要件②ログファイル名に時系列を挿入
REM 20/03/02 要件③標準出力と標準エラー両方を出力する仕様へ変更
REM 20/03/02 要件④使用コマンド「netstat -n」を「netstat -ano」へ変更

REM フォルダ名の決定と作成/移動

REM 
REM echo winsv_checker
set OUTSTR=%1
set ERROUT=%1.winsv_checker_errorlog.txt

for /f "usebackq tokens=*" %%s IN (`cd`) DO @set backdir=%%s
set logfolder=%1

if "%logfolder%" EQU "" (
    echo カレントディレクトリへログを展開します。
    set OUTSTR=.\SPMWindows
    set ERROUT=.\SPMWindows_winsv_checker-err.txt
) else (
    echo make logfolder %logfolder%
    if not exist "%logfolder%" (
        mkdir "%logfolder%"
    )
    cd "%logfolder%"
    echo %logfolder%へログを展開します。
)

REM ログファイル名の決定
set datestr=%date:/=%
set timestrs=%time:~0,2%%time:~3,2%%time:~6,2%
set timestr=%timestrs: =0%
REM 
set logfilename=%OUTSTR%.winsvcheck_%datestr%_%timestr%

rem echo logfilename=%logfilename%

echo 'systeminfo' >>%ERROUT%
echo ### systeminfo %date% %time% ### >> %logfilename%.log
systeminfo >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo 'powershell -command Get-HotFix' >>%ERROUT%
echo ### powershell -command Get-HotFix %date% %time% ### >> %logfilename%.log
powershell -command Get-HotFix >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo 'ipconfig' >>%ERROUT%
echo ### ipconfig %date% %time% ### >> %logfilename%.log
ipconfig >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo 'netstat' >>%ERROUT%
echo ### netstat -ano %date% %time% ### >> %logfilename%.log
netstat -ano >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo '### powershell get_programinfo.ps1 ###' >> %logfilename%.log
echo 'reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' >>%ERROUT%
echo 'reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' >>%ERROUT%
rem powershell -NoProfile -ExecutionPolicy Unrestricted -Command %backdir%get_programinfo.ps1 -logfilename %logfilename% -date %date% -time %time% 2>>%ERROUT%
powershell -NoProfile -ExecutionPolicy Unrestricted -Command "& { ..\get_programinfo.ps1 -logfilename %logfilename% -date %date% -time %time%} " 2>>%ERROUT%

echo 'sc query state= all' >>%ERROUT%
echo ### sc query %date% %time% ### >> %logfilename%.log
sc query state= all >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo powershell -command get-wmiobject win32_service >> %ERROUT%
echo ### get-wmiobject win32_service %date% %time% ### >> %logfilename%.log
powershell -command get-wmiobject win32_service "| select Name,State,StartMode,StartName" >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo 'schtasks /query' >>%ERROUT%
echo ### schtasks  %date% %time% ### >> %logfilename%.log
schtasks /query >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo 'net user' >>%ERROUT%
echo ### net user %date% %time% ### >> %logfilename%.log
net user >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo ### net user ALL LOCAL USERS %date% %time% ### >> %logfilename%.log

for /f "tokens=1-3 skip=4" %%a in ('net user') do (
if not "%%a"=="コマンドは正常に終了しました。" echo %%a >> userlist.log
if not "%%b"=="" echo %%b >> userlist.log
if not "%%c"=="" echo %%c >> userlist.log
)
for /f "usebackq" %%l in ("userlist.log") do (
net user ^"%%l^" >> %logfilename%.log
echo.  >> %logfilename%.log
)
del userlist.log

echo 'ipconfig' >>%ERROUT%
echo ### ipconfig all  %date% %time% ### >> %logfilename%.log 2>>%ERROUT%
ipconfig /all >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo 'w32tm /query /status' >>%ERROUT%
echo ### w32tm   %date% %time% ### >> %logfilename%.log 2>>%ERROUT%
w32tm /query /status >> %logfilename%.log
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo 'netsh advfirewall firewall show rule name=all dir=in' >>%ERROUT%
echo ### netsh advfirewall firewall in  %date% %time% ### >> %logfilename%.log
netsh advfirewall firewall show rule name=all dir=in >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

echo 'netsh advfirewall firewall show rule name=all dir=out'>>%ERROUT%
echo ### netsh advfirewall firewall out  %date% %time% ### >> %logfilename%.log
netsh advfirewall firewall show rule name=all dir=out >> %logfilename%.log 2>>%ERROUT%
echo.  >> %logfilename%.log
echo.  >> %logfilename%.log

REM PROCESS.PS1を呼び出し
echo ### NETSTATの実行プロセスリストを発行  %date% %time% ### >> %logfilename%.log
echo "→実行結果は「PROC_<hostname>_<実行日時>.csv」を参照ください。" >> %logfilename%.log

echo "powershell -NoProfile -ExecutionPolicy Unrestricted ..\process.ps1" %OUTSTR% >>%ERROUT%
rem powershell -NoProfile -ExecutionPolicy Unrestricted %backdir%\process.ps1 %OUTSTR% 2>>%ERROUT%
powershell -NoProfile -ExecutionPolicy Unrestricted ..\process.ps1 %OUTSTR% 2>>%ERROUT%

@echo off

REM BATファイルの作業フォルダへ回帰

cd %backdir%
