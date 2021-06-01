Param( $arg1 )

Get-ChildItem -Path(
    'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 
    'HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') | Foreach-Object {
        Get-ItemProperty $_.PsPath | Select-Object DisplayName, DisplayVersion, Publisher 
    } | Export-Csv -Encoding UTF8 -Path $arg1'.applist.csv'

$outfile=$arg1+".netstat.txt"
echo 'port list'
netstat -nao | Set-Content -Encoding UTF8 $outfile


$outfile=$arg1+".tasklist.txt"
echo 'process list'
tasklist | Set-Content -Encoding UTF8 $outfile

