@echo off

REM winsv_checker �o�̓t�H���_��
REM 

REM �ύX�o��
REM 2021.03.01 Ver. 1.2a ������1�ɕύX�A�G���[���O�t�@�C���͏o�̓t�H���_�z���ɂȂ邽��
REM 2021.01.19 Ver. 1.2 �o�̓t�H���_�����݂��Ă���ꍇ�̏�����ǉ�
REM 2020.05.27 Ver. 1.1 Error �o�͂�1�t�@�C����
REM 2020.05.11 Ver. 1.0
REM 2020.05.11 �o�̓t�@�C�����̕ύX �R���s���[�^�� ���폜�A��1�����������擪�ɕt�^
REM 2021.04.27 �C���X�g�[���ς݃t�@�C���ꗗ�擾������get_programinfo.ps1�ōs���悤�ɏC��

REM 20/02/26 �R�����g�����̎��F���̂��߁u%date%�v�u%time%�v�Ԃɋ󔒂�}��
REM 20/02/26 �R�}���h�unet user�v��ɁA�󔒂̂��郆�[�U�A�J�E���g�Ή��̂��߁u^"�v��}��
REM 20/03/02 �v���@��������ɂă��O�i�[�t�H���_�쐬�@�\��ǉ�
REM 20/03/02 �v���A���O�t�@�C�����Ɏ��n���}��
REM 20/03/02 �v���B�W���o�͂ƕW���G���[�������o�͂���d�l�֕ύX
REM 20/03/02 �v���C�g�p�R�}���h�unetstat -n�v���unetstat -ano�v�֕ύX

REM �t�H���_���̌���ƍ쐬/�ړ�

REM 
REM echo winsv_checker
set OUTSTR=%1
set ERROUT=%1.winsv_checker_errorlog.txt

for /f "usebackq tokens=*" %%s IN (`cd`) DO @set backdir=%%s
set logfolder=%1

if "%logfolder%" EQU "" (
    echo �J�����g�f�B���N�g���փ��O��W�J���܂��B
    set OUTSTR=.\SPMWindows
    set ERROUT=.\SPMWindows_winsv_checker-err.txt
) else (
    echo make logfolder %logfolder%
    if not exist "%logfolder%" (
        mkdir "%logfolder%"
    )
    cd "%logfolder%"
    echo %logfolder%�փ��O��W�J���܂��B
)

REM ���O�t�@�C�����̌���
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
if not "%%a"=="�R�}���h�͐���ɏI�����܂����B" echo %%a >> userlist.log
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

REM PROCESS.PS1���Ăяo��
echo ### NETSTAT�̎��s�v���Z�X���X�g�𔭍s  %date% %time% ### >> %logfilename%.log
echo "�����s���ʂ́uPROC_<hostname>_<���s����>.csv�v���Q�Ƃ��������B" >> %logfilename%.log

echo "powershell -NoProfile -ExecutionPolicy Unrestricted ..\process.ps1" %OUTSTR% >>%ERROUT%
rem powershell -NoProfile -ExecutionPolicy Unrestricted %backdir%\process.ps1 %OUTSTR% 2>>%ERROUT%
powershell -NoProfile -ExecutionPolicy Unrestricted ..\process.ps1 %OUTSTR% 2>>%ERROUT%

@echo off

REM BAT�t�@�C���̍�ƃt�H���_�։�A

cd %backdir%
