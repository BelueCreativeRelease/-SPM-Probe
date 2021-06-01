#
reg query 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion' /f * /d /t REG_SZ /reg:64 | % { $_-replace "ProductId.*","ProductId  **SECRET** " }
#
