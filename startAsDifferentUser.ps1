$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -LiteralPath $RegPath 'AutoAdminLogon' -Value "0" -type String

# このコンピューターへのリモート接続を許可する → ON◯
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -Name "RemoteDesktop-Shadow-In-TCP"
Enable-NetFirewallRule -Name "RemoteDesktop-UserMode-In-TCP"
Enable-NetFirewallRule -Name "RemoteDesktop-UserMode-In-UDP"

#アプリのサイレントインストール◯
Write-Host "アプリのインストール中"
Start-Process -FilePath "C:\インストーラー\ChromeSetup.exe" -ArgumentList "/silent /install" -Wait
Start-Process -FilePath 'C:\Program Files\Google\Chrome\Application\chrome.exe' -ArgumentList 'https://google.com/'
Start-Process -FilePath "C:\インストーラー\adobe.exe" -ArgumentList "/sAll /rs /rps /l /msi EULA_ACCEPT=YES" -Wait
C:\インストーラー\setup.exe /configure C:\インストーラー\configuration.xml
Write-Host "インストール完了。" 

#拡張子表示(エクスプローラー再起動後反映)
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f

#高速スタートアップの無効(スリープの代わりに画面をロックする)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "1" /f

# タスクビューを無効にする
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

#スキャンフォルダの作成
New-Item -Name scan -ItemType Directory -Path C:\
New-SmbShare -Name scan -Path C:\scan
$folderPath = "C:\scan"
takeown /f C:\scan
$everyone = "everyone"
icacls $folderPath /grant "$($everyone):(OI)(CI)F" /t
$DtFol = [Environment]::GetFolderPath('Desktop')
$WsShell = New-Object -ComObject WScript.Shell
$Shortcut = $WsShell.CreateShortcut($DtFol + "\scan.lnk")
$Shortcut.TargetPath = "C:\scan"
$Shortcut.IconLocation = "C:\scan"
$Shortcut.Save()

#タスクバーの設定
Remove-Item -Path "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Force -Recurse -ErrorAction SilentlyContinue
Stop-Process -ProcessName explorer -Force
Start-Process explorer
$taskbar_layout =
@"
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1">
  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="C:\Program Files\Google\Chrome\Application\chrome.exe" /> 
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
 </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
"@

[System.IO.FileInfo]$provisioning = "$($env:ProgramData)\provisioning\tasbar_layout.xml"
if (!$provisioning.Directory.Exists) {
    $provisioning.Directory.Create()
}

$taskbar_layout | Out-File $provisioning.FullName -Encoding utf8

$settings = [PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
    Value = $provisioning.FullName
    Name  = "StartLayoutFile"
    Type  = [Microsoft.Win32.RegistryValueKind]::ExpandString
},
[PSCustomObject]@{
    Path  = "SOFTWARE\Policies\Microsoft\Windows\Explorer"
    Value = 1
    Name  = "LockedStartLayout"
} | group Path

foreach ($setting in $settings) {
    $registry = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | % {
        if (!$_.Type) {
            $registry.SetValue($_.name, $_.value)
        }
        else {
            $registry.SetValue($_.name, $_.value, $_.type)
        }
    }
    $registry.Dispose()
}

set-executionpolicy restricted -f
Read-Host "終了しました。キーを押してください。"