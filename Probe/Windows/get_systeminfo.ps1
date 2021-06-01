# get_ systeminfo.ps1
systeminfo | % { $_-replace "プロダクト ID.*","Product ID:  **SECRET** " }
#