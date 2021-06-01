#
# プログラム一覧の取得処理
#
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
# の読み出し、ファイル書き出しを行う
#

#
# usage: ./~ -logfilename [出力先ファイル名(拡張子不要)] (-date [日付]) (-time [時間])
# example: ./ -logfilename exam -date exam -time exam
#

Param(
    [parameter(mandatory=$true)]$logfilename, # 出力先ファイル名(拡張子不要)
    $date, # 日付
    $time # 時間
)

# 実行権限付与
Set-ExecutionPolicy RemoteSigned -Scope Process
# 一時的にGet-Contentで読み出す用のファイルを作成
$tmpreadfile = "tmpreadfile_getprograminfo"
# 一時的に書き出す用のファイルを作成

Add-Content -path "$logfilename.log" -value "### reg query 64bit $date $time ###" -encoding String
# 一覧ファイルの読み出し
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall > $tmpreadfile
$shapedfile = @(Get-Content $tmpreadfile) -as [string[]]

foreach ($line in $shapedfile) {
    # プログラム名がuuidになっている場合、プログラム名をDisplaynameで置換する
    if(($line -match "\{[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\}")`
     -Or ($line -match "\{[0-9a-f]{32}\}"))
    {
        $programproperty = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$($matches[0])"
        
        # Displaynameがあればuuidを置換して出力、なければそのまま出力
        if([string]::IsNullOrEmpty($($programproperty.displayname))){
            Add-Content -path "$logfilename.log" -value $line -encoding String
        }
        else{
            $line = $line.Replace($($matches[0]), $($programproperty.displayname))
            Add-Content -path "$logfilename.log" -value $line -encoding String
        }
    }
    # プログラム名がuuidになっていなければそのまま出力
    else{
        Add-Content -path "$logfilename.log" -value $line -encoding String
    }
}

# 改行の挿入
Add-Content -path "$logfilename.log" -value "" -encoding String
Add-Content -path "$logfilename.log" -value "" -encoding String

Add-Content -path "$logfilename.log" -value "### reg query 32bit $date $time ###" -encoding String
# 一覧ファイルの読み出し
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall > $tmpreadfile 
$shapedfile = @(Get-Content $tmpreadfile) -as [string[]]

foreach ($line in $shapedfile) {
    # プログラム名がuuidになっている場合、プログラム名をDisplaynameで置換する
    if(($line -match "\{[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\}")`
     -Or ($line -match "\{[0-9a-f]{32}\}"))
    {
        $programproperty = Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($matches[0])"
        
        # Displaynameがあればuuidを置換して出力、なければそのまま出力
        if([string]::IsNullOrEmpty($($programproperty.displayname))){
            Add-Content -path "$logfilename.log" -value $line -encoding String
        }
        else{
            $line = $line.Replace($($matches[0]), $($programproperty.displayname))
            Add-Content -path "$logfilename.log" -value $line -encoding String
        }
    }
    # プログラム名がuuidになっていなければそのまま出力
    else{
        Add-Content -path "$logfilename.log" -value $line -encoding String
    }
}
# 改行の挿入
Add-Content -path "$logfilename.log" -value "" -encoding String
Add-Content -path "$logfilename.log" -value "" -encoding String

# 一時ファイルの削除
rm $tmpreadfile