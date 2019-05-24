##########################################################################
#
# イベントログチェック
#  インストール
#
##########################################################################
$G_ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$G_LogName = "Install"				# ログファイル名


# 変数 Include
$Include = Join-Path $G_ScriptDir "ConfigCommon.ps1"
if( -not(Test-Path $Include)){
	echo "[FAIL] 環境異常 $Include が無い"
	exit
}
. $Include

##########################################################################
# ログ出力
##########################################################################
function Log( $LogString ){

	$Now = Get-Date

	$Log = "{0:0000}-{1:00}-{2:00} " -f $Now.Year, $Now.Month, $Now.Day
	$Log += "{0:00}:{1:00}:{2:00}.{3:000} " -f $Now.Hour, $Now.Minute, $Now.Second, $Now.Millisecond
	$Log += $LogString

	if( $G_LogName -eq $null ){
		$G_LogName = "LOG"
	}

	$LogFile = $G_LogName +"_{0:0000}-{1:00}-{2:00}.log" -f $Now.Year, $Now.Month, $Now.Day

	# ログフォルダーがなかったら作成
	if( -not (Test-Path $C_LogPath) ) {
		New-Item $C_LogPath -Type Directory
	}

	$LogFileName = Join-Path $C_LogPath $LogFile

	Write-Output $Log | Out-File -FilePath $LogFileName -Encoding Default -append

	Return $Log
}

#######################################################
# 管理権限で実行されているか確認
#######################################################
function HaveIAdministrativePrivileges(){
	$WindowsPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
	$IsRoleStatus = $WindowsPrincipal.IsInRole("Administrators")
	return $IsRoleStatus
}
#################################################################################
# スケジュール削除
#################################################################################
function RemoveSchedule(
	[String]$ScheduleName
){

	$ScheduleFllName = $ScheduleName

	Log "[INFO] スケジュール : $ScheduleFllName 削除開始"

	# 実行終了しているかの確認
	$ScheduleStatus = schtasks /Query /TN $ScheduleFllName
	if($LastExitCode -ne 0){
		Log "[INFO] スケジュール : $ScheduleFllName は存在しない"
		return 0
	}

	if( -not(($ScheduleStatus[4] -match "準備完了") -or ($ScheduleStatus[4] -match "無効")) ){
		# 実行終了していなかったら 15 秒待つ
		Log "[INFO] スケジュール : $ScheduleFllName が終了していないので15秒待つ"
		sleep 15
		$ScheduleStatus = schtasks /Query /TN $ScheduleFllName
		if($LastExitCode -ne 0){
			Log "[FAIL] スケジュール : $ScheduleFllName 状態確認失敗"
			Log "[FAIL] ●○●○ 処理異常終了 ●○●○"
			return 99
		}
		if( -not(($ScheduleStatus[4] -match "準備完了") -or ($ScheduleStatus[4] -match "無効")) ){
			Log "[FAIL] スケジュール : $ScheduleFllName 終了せず"
			Log "[FAIL] ●○●○ 処理異常終了 ●○●○"
			return 99
		}
	}

	Log "[INFO] スケジュール : $ScheduleFllName 削除開始"
	schtasks /Delete /TN "$ScheduleFllName" /F
	if($LastExitCode -ne 0){
		Log "[FAIL] スケジュール : $ScheduleFllName 削除失敗"
		Log "[FAIL] ●○●○ 処理異常終了 ●○●○"
		return 99
	}
	Log "[INFO] スケジュール : $ScheduleFllName 削除完了"
	return 0
}



##########################################################################
#
# Main
#
##########################################################################
Log "[INFO] ============== セットアップ開始 =============="

$Status = HaveIAdministrativePrivileges
if($Status -ne $true){
	Log "[FAIL] 管理権限で実行してください"
	exit
}

RemoveSchedule "CheckEventLog\Check EventLog Schedule"
RemoveSchedule "CheckEventLog\Remove ExecLog Schedule"

#------------------------------
Log "[INFO] イベントログチェック本体登録"
$TaskPath = $C_ScheduleDir
$TaskName = $C_CheckEventLogTaskName
$RunTime = "00:00"
$Script = Join-Path $G_ScriptDir $C_CheckEventLogTaskScriptName

$FullTaskName = $TaskPath + "\" + $TaskName

SCHTASKS /Create /tn $FullTaskName /tr "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe $Script" /ru "SYSTEM" /sc minute /mo $C_Interval /st $RunTime /F

if($LastExitCode -ne 0){
	Log "[FAIL] スケジュール : $FullTaskName 登録失敗"
	Log "[FAIL] ●○●○ 処理異常終了 ●○●○"
	exit
}
Log "[INFO] スケジュール : $FullTaskName 登録完了"

#------------------------------
Log "[INFO] 実行ログ削除登録"
$TaskPath = $C_ScheduleDir
$TaskName = $C_RemoveExecLogTaskName
$RunTime = $C_RemveLogTime
$Script = Join-Path $G_ScriptDir $C_RemoveExecLogTaskScriptName

$FullTaskName = $TaskPath + "\" + $TaskName

SCHTASKS /Create /tn $FullTaskName /tr "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe $Script" /ru "SYSTEM" /sc daily /st $RunTime /F

if($LastExitCode -ne 0){
	Log "[FAIL] スケジュール : $FullTaskName 登録失敗"
	Log "[FAIL] ●○●○ 処理異常終了 ●○●○"
	exit
}
Log "[INFO] スケジュール : $FullTaskName 登録完了"
Log "[INFO] ============== セットアップ終了 =============="
