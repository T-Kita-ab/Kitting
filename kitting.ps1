#ユーザー・PC名作成
$userName = Read-Host "ユーザー名を入力してください"
$rawPassword = Read-Host "パスワードを入力してください"
$PCName = Read-Host "PC名を入力してください"
$password = convertto-securestring $rawPassword -AsPlainText -Force
New-LocalUser -Name $userName -Password $password -PasswordNeverExpires
Add-LocalGroupMember -Group 'Administrators' -Member $userName
Rename-Computer -NewName $PCName -Force

#再起動後、powershellで処理を続行
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUsername = $userName
$DefaultPassword = $rawPassword
Set-ItemProperty -LiteralPath $RegPath 'AutoAdminLogon' -Value "1" -type String 
Set-ItemProperty -LiteralPath $RegPath 'DefaultUsername' -Value "$DefaultUsername" -type String 
Set-ItemProperty -LiteralPath $RegPath 'DefaultPassword' -Value "$DefaultPassword" -type String
$regRunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
$powerShell = (Join-Path $env:windir "system32\WindowsPowerShell\v1.0\powershell.exe")
$script = "C:\Practice\reseult.ps1"
$restartKey = "Restart-And-RunOnce"
Set-ItemProperty -path $regRunOnceKey -Name $restartKey -Value "$powerShell $script"
Restart-Computer -Force