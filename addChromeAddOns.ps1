$RegPath = "HKLM:SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist"
#拡張機能ID + ";" + https://clients2.google.com/service/update2/crx
$addOnID1 = "gmbmikajjgmnabiglmofipeabaddhgne;https://clients2.google.com/service/update2/crx"
$addOnID2 = "ppnbnpeolgkicgegkbkbjmhlideopiji;https://clients2.google.com/service/update2/crx"
#レジストリにキー(フォルダ)が作られていないため、1階層ずつ作成する(一度に複数階層作ることはできない)
if (-not (Test-Path $RegPath)){
    New-Item "HKLM:SOFTWARE\Policies\Google" -Force
    New-Item "HKLM:SOFTWARE\Policies\Google\Chrome" -Force
    New-Item "HKLM:SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" -Force
    #拡張機能のサブキーは必ず番号の名前を付ける。複数追加する場合は連番にする。
    New-ItemProperty -LiteralPath $RegPath -Name "1" -Value "$addOnID1" -PropertyType "String" -Force
    New-ItemProperty -LiteralPath $RegPath -Name "1" -Value "$addOnID2" -PropertyType "String" -Force
}

#拡張機能を削除する場合(現状削除はできるがエラーがでる)
#Remove-ItemProperty -LiteralPath $RegPath -Name "1" -Force
#Remove-ItemProperty -LiteralPath $RegPath -Name "2" -Force