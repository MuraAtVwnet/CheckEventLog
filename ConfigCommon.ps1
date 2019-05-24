##########################################################################
#
# イベントログチェック
#  環境設定(共通部分)
#
##########################################################################

### 必ず設定する項目 ###

# メール宛先(複数指定可能)
$C_RcpTos = @"
mailto@example.com
"@

# メール送信元(1つのみ)
$C_MailFrom = "mailfrom@example.com"


# SMTP 認証用パスワード(SMTP AUTH 使う場合のみ設定)
$C_SMTPPassword = ""



### 必要に応じて設定変更する項目 ###

# 監視間隔(分)
$C_Interval = 10

# 実行ログ保存期間(日)
$C_KeepLog = 5

# 実行ログ削除時刻
$C_RemveLogTime = "08:00"

# 前回処理時間がなかった時の遡及時間(分)
$C_StartDelay = 30

# 一部のイベントログのみをチェックするか否か
# これを $False にすると全てのイベントログをチェックする
$C_CheckSelectEventLog = $True

# チェック対象のイベントログ名(一部のイベントログのみチェックする時用)
$C_CheckEventLogNames = @"
Application
System
"@

# スキップするログ(全てのイベントログをチェックする時用)
$C_SkipLogs = @"
Security
Microsoft-Windows-TaskScheduler/Operational
"@

# イベントの XML 出力をするか
$C_OutputEventXML = $True



### 基本的に設定変更しない項目 ###

# 実行ロ出力先
$C_LogPath = Join-Path $G_ScriptDir "\Log"

# スケジュールフォルダー
$C_ScheduleDir = "MURA\CheckEventLog"

# イベントチェックタスク名と実行スクリプト
$C_CheckEventLogTaskName = "Check EventLog Schedule"
$C_CheckEventLogTaskScriptName = "CheckEventLog.ps1"

# 実行ログ削除登録タスク名と実行スクリプト
$C_RemoveExecLogTaskName = "Remove ExecLog Schedule"
$C_RemoveExecLogTaskScriptName = "RemoveExecLog.ps1"

# イベントを最後に取った日時を保管しているファイル
$C_GetTimeFile = Join-Path $G_ScriptDir "GetDate.dat"


