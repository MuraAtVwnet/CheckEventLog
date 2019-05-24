##########################################################################
#
# ログ削除(For イベントログチェック)
#
##########################################################################
##### スクリプトが格納されているディレクトリー
$G_ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent

# 変数 Include
$Include = Join-Path $G_ScriptDir "ConfigCommon.ps1"
if( -not(Test-Path $Include)){
	$temp = Log "[FAIL] 環境異常 $Include が無い"
	exit
}
. $Include


# 処理ルーチン
$G_LogName = "LogRemove"
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


##########################################################################
# Main
##########################################################################

Log "[INFO] =========== 処理開始 ==========="

$TergetFolder = Join-Path $C_LogPath "*.log"

# 指定フォルダーが存在していなかった
if( -not (Test-Path $TergetFolder) ){
	Log "[Error] $TergetFolder が存在しません"
}
else{
	# 今日の日付
	$Now = Get-Date

	# 削除する日
	$DeleteDate = $Now.AddDays(-$C_KeepLog)

	# ファイル一覧取得
	$Files = Get-ChildItem $TergetFolder | ? {$_.Attributes -eq "Archive"}

	Log "[INFO] -=-=-=-=-=-= $TergetFolder の $DeleteDate 以前のファイル削除 -=-=-=-=-=-="

	foreach( $File in $Files ){
		# 保管期間より古いファイル
		$Date = $File.LastWriteTime
		$FileName = $File.FullName
		if( ($File.GetType().Name -eq "FileINFO") -and ( $Date -le $DeleteDate )){
			Log "[INFO] Remove $FileName ($Date)"
			Remove-Item $FileName -Force
		}
	}
}

Log "[INFO] =========== 処理終了 ==========="
