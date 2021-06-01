#
# Param( $arg1 )
# $Outfile=$arg1+".AllKBTitles.txt"

#
$Session  = New-Object -ComObject Microsoft.Update.Session
$Searcher = $Session.CreateUpdateSearcher()

#
$HistoryCount = $Searcher.GetTotalHistoryCount()
$MicrosoftUpdates = $Searcher.QueryHistory(1,$HistoryCount)

#
$HistoryCountOutput="Count: "+$HistoryCount 
Write-Output $HistoryCountOutput

#
# $MicrosoftUpdates | Select-Object -Property Date,Operation,ResultCode,Title

# $MicrosoftUpdates | Select-Object -Property Title

ForEach( $MSUpdate in $MicrosoftUpdates ) {
  $OutputLine = $MSUpdate.Date.ToString("yyyy/MM/dd-HH:mm:ss") + " : " + $MSUpdate.Title
  if ($MSUpdate.Title.Length -gt 0) {
    Write-Output $OutputLine 
    # $OutputLine | Out-File -Append -Encoding UTF8 $Outfile
    # $OutputLine | Set-Content -Encoding UTF8 $Outfile
  }
}
