#
# Write-Host( '$Args[0]:' + $Args[0] )

# 実行権限付与
Set-ExecutionPolicy RemoteSigned -Scope Process

# CSVファイル名作成(PROC_<hostname>_<datetime>.csv)
$csdate = get-date -format yyyyMMdd
$cstime = get-date -format hhmmss
$hostna = hostname
#
$csfile = $Args[0] + ".PROC_" + $hostna + "_" + $csdate + "_" + $cstime + ".csv"

# Write-Host $csfile

# NETSTATのLISTENINGだけを抽出
$liport = netstat -ano | select-string LISTENING

# 表を作成
Write-Output "Plotocol,LocalAddress,OutbandAddress,Status,PID,Name,Path,Company,FileVersion,ProductVersion,Description,Product,MainModule,ProcessName,StartTime" | Set-Content -Encoding Default $csfile

# LISTENINGに対して、Get-Processを相対抽出
foreach ($onport in $liport){
	$portin = -split $onport.line
	$p_name = (get-process -id $portin[4]).Name
    $p_path = (get-process -id $portin[4]).Path
	$p_comp = (get-process -id $portin[4]).Company
	$p_five = (get-process -id $portin[4]).FileVersion
	$p_prve = (get-process -id $portin[4]).ProductVersion
	$p_desc = (get-process -id $portin[4]).Description
	$p_prod = (get-process -id $portin[4]).Product
	$p_mamo = (get-process -id $portin[4]).MainModule
	$p_prna = (get-process -id $portin[4]).ProcessName
	$p_stti = (get-process -id $portin[4]).StartTime

	$p_writ = $portin[0] + "," + $portin[1] + "," + $portin[2] + "," + $portin[3] + "," + $portin[4] + "," + $p_name + "," + $p_path + "," + $p_comp + "," + $p_five + "," + $p_prve + "," + $p_desc + "," + $p_prod + "," + $p_mamo + "," + $p_prna + "," + $p_stti

    Write-Output $p_writ | Add-Content $csfile -Encoding Default
}
