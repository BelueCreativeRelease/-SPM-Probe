'�f�B���N�g�������̃t�@�C����zip�t�@�C���Ɉ��k
'
'�g����: wscript makezip.vbs zip�t�@�C���� �f�B���N�g���p�X

Dim zipFileName, sourceDir

'�R�}���h���C�������̏���
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

  '�������O�̃t�@�C�������łɑ��݂��Ă���΍폜
  If fsObj.FileExists(ZipPath) = True Then
    fsObj.DeleteFile(path)
  End If

  '���zip�t�@�C�����쐬����
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

  'Zip�t�H���_���̃t�@�C����
  fileCount = 0

  For Each srcFile In srcFolder.files
    'Zip�t�H���_�Ɉ��k�Ώۂ̃t�@�C�����R�s�[����
    zipFolder.CopyHere(srcFile.path)
    fileCount = fileCount + 1

    '���k���I������܂ő҂�
    Do Until zipFolder.Items().Count=fileCount
      Wscript.sleep 200
    Loop
  Next

End Sub

