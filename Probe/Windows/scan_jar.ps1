$oldpwd=pwd
cd \
Get-WmiObject Win32_LogicalDisk | Where-Object -filterScript { $_.DriveType -ne 5 } | ForEach-Object -Process{ echo $_.Name ; where.exe /R $_.Name '*.jar' }
cd $oldpwd
