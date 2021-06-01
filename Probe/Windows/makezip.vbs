'ディレクトリ直下のファイルをzipファイルに圧縮
'
'使い方: wscript makezip.vbs zipファイル名 ディレクトリパス

Dim zipFileName, sourceDir

'コマンドライン引数の処理
If WScript.Arguments.Count <> 2 Then
  WScript.echo("usage: wscript makezip output directory")
  WScript.Quit(-1)
End If

zipFileName = WScript.Arguments.Item(0)
sourceDir = WScript.Arguments.Item(1)

Call makeEmptyZipFile(zipFileName)
Call addToZipFile(zipFileName, sourceDir)




Sub makeEmptyZipFile(path)
  Dim fsObj

  Set fsObj = CreateObject("Scripting.FileSystemObject")

  '同じ名前のファイルがすでに存在していれば削除
  If fsObj.FileExists(ZipPath) = True Then
    fsObj.DeleteFile(path)
  End If

  '空のzipファイルを作成する
  With fsObj.CreateTextFile(path, True)
    .Write "PK" & Chr(5) & Chr(6) & String(18,0)
    .Close
  End With

  Set fsObj = Nothing
End Sub



Sub addToZipFile(zipPath, srcPath)
  Dim fsObj, appObj, zipFolder, fileCount, srcFolder, srcFile

  Set fsObj = CreateObject("Scripting.FileSystemObject")
  Set appObj = CreateObject("Shell.Application")

  Set zipFolder = appObj.NameSpace(fsObj.GetAbsolutePathName(zipPath))
  Set srcFolder = fsObj.getFolder(fsObj.GetAbsolutePathName(srcPath))

  'Zipフォルダ内のファイル数
  fileCount = 0

  For Each srcFile In srcFolder.files
    'Zipフォルダに圧縮対象のファイルをコピーする
    zipFolder.CopyHere(srcFile.path)
    fileCount = fileCount + 1

    '圧縮が終了するまで待つ
    Do Until zipFolder.Items().Count=fileCount
      Wscript.sleep 200
    Loop
  Next

End Sub

