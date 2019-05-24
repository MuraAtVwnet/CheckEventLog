########################################################
# テスト用エラーのイベントログ出力
########################################################

#######################################################
# 管理権限で実行されているか確認
#######################################################
function HaveIAdministrativePrivileges(){
    $WindowsPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $IsRoleStatus = $WindowsPrincipal.IsInRole("Administrators")
    return $IsRoleStatus
}

#######################################################
# Main
#######################################################
$Status = HaveIAdministrativePrivileges

if( $Status -eq $true ){
	[Diagnostics.EventLog]::WriteEntry("Test", "This is test event.", "Error", 9000)
}
else{
	echo "管理権限で実行してください"
}

