# get_ systeminfo.ps1
systeminfo | % { $_-replace "�v���_�N�g ID.*","Product ID:  **SECRET** " }
#