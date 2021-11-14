##########################################################################
#
# イベントログチェック
#  エラーを見つけたらメールを送る
#
##########################################################################
$G_ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$G_LogName = "EventLogCheck"				# ログファイル名

# 変数 Include
$Include = Join-Path $G_ScriptDir "ConfigCommon.ps1"
if( -not(Test-Path $Include)){
	echo "[FAIL] 環境異常 $Include が無い"
	exit
}
. $Include

$Include = Join-Path $G_ScriptDir "ConfigEvent.ps1"
if( -not(Test-Path $Include)){
	echo "[FAIL] 環境異常 $Include が無い"
	exit
}
. $Include


$Include = Join-Path $G_ScriptDir "ConfigNode.ps1"
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

##########################################################################
# メール送信
##########################################################################
function MailSend(
		$MSA,				# メールサーバー
		$MailFrom,			# 送信元
		$RcpTos,			# 宛先
		$ProjectName,		# プロジェクト名
		$Mode,				# モード(エラーとか)
		$Manufacturer,		# メーカー
		$Model,				# モデル
		$SerialNumber,		# シリアル番号
		$OS,				# OSバージョン
		$HostName,			# ホスト名
		$Alias,				# Alias
		$ServerType,		# サーバータイプ
		$HostIPv4Address,	# IPv4 アドレス
		$HostIPv6Address,	# IPv6 アドレス
		$LogName,			# イベントログ名
		$EventTime,			# イベント発生日時
		$EventSource,		# イベントソース
		$EventID,			# イベント ID
		$EventMessage,		# メッセージ
		$EventCount,		# 発生件数
		$EventXMLData = ""	# XML データー
	){

	switch( $Mode ){
		"Error" { # エラー
			$SubjectSting = "エラーを検出しました"
			$Status = "Error"
		}

		"Warning" { # 警告
			$SubjectSting = "指定の警告を検出しました"
			$Status = "Warning"
		}

		"Information" { # 情報
			$SubjectSting = "指定の情報を検出しました"
			$Status = "Information"
		}
	}

	# メールデーター作成
	$Mail = New-Object Net.Mail.MailMessage
	$Mail.From = $MailFrom

	# 宛先
	foreach( $RcpTo in $RcpTos ){
		$Mail.To.Add($RcpTo)
	}

	$Mail.Subject = "【$ProjectName】イベントログに$SubjectSting $HostName($ServerType) / $EventSource / $EventID"
	$Mail.Body =
		"$Status イベントログ情報( $EventCount 件)`n" +
		"-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-`n" +
		"Status         : $Status`n" +
		"Project Name   : $ProjectName`n" +
		"Host Name      : $HostName`n" +
		"Alias          : $Alias`n" +
		"Server Type    : $ServerType`n" +
		"IPv4 Address   : $HostIPv4Address`n" +
		"IPv6 Address   : $HostIPv6Address`n" +
		"Manufacturer   : $Manufacturer`n" +
		"Model          : $Model`n" +
		"Serial Number  : $SerialNumber`n" +
		"OS             : $OS`n" +
		"Log Name       : $LogName`n" +
		"Generated Time : $EventTime`n" +
		"Event Source   : $EventSource`n" +
		"Event ID       : $EventID`n" +
		"Message :`n" +
		"$EventMessage`n"

	if($C_OutputEventXML){
		$Mail.Body += "XML :`n" +
		"$EventXMLData`n"
	}
	$Mail.Body +=
		"-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"

	Log "[INFO] -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
	Log "[INFO]【$ProjectName】イベントログに$SubjectSting $HostName($ServerType) / $EventSource / $EventID"
	Log "[INFO]"
	Log "[INFO] $Status イベントログ情報( $EventCount 件)"
	Log "[INFO] -----------------------------------"
	Log "[INFO] Status         : $Status"
	Log "[INFO] ProjectName    : $ProjectName"
	Log "[INFO] Host Name      : $HostName"
	Log "[INFO] Alias          : $Alias"
	Log "[INFO] Server Type    : $ServerType"
	Log "[INFO] IPv4 Address   : $HostIPv4Address"
	Log "[INFO] IPv6 Address   : $HostIPv6Address"
	Log "[INFO] Manufacturer   : $Manufacturer"
	Log "[INFO] Model          : $Model"
	Log "[INFO] Serial Number  : $SerialNumber"
	Log "[INFO] OS             : $OS"
	Log "[INFO] Log Name       : $LogName"
	Log "[INFO] Generated Time : $EventTime"
	Log "[INFO] Event Source   : $EventSource"
	Log "[INFO] Event ID       : $EventID"
	Log "[INFO] Message :"
	Log "[INFO] $EventMessage"
	if($C_OutputEventXML){
		Log "[INFO] XML :"
		Log "[INFO] $EventXMLData"
	}
	Log "[INFO] -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"

	# メール送信
	# SubMission
	if( $C_Submission ){
		$Password = $C_SMTPPassword
		if( ($Password -ne $null) -and ($Password -ne "") ){
			$SmtpClient = New-Object Net.Mail.SmtpClient($MSA, 587)
			$SmtpClient.Credentials = New-Object System.Net.NetworkCredential($MailFrom, $Password)
		}
	}
	# TCP/25
	else{
		$SmtpClient = New-Object Net.Mail.SmtpClient($MSA)
	}

	try{
		$SmtpClient.Send($Mail)
	}
	catch{
		Log "[ERROR] $Status メール送信に失敗しました MSA : $MSA"
	}

	Log "[INFO] $Status $LogName $EventTime $EventSource $EventID mail sended"
	$Mail.Dispose()
}


##########################################################################
# XML 整形
##########################################################################
function Format-XML([xml]$xml, $indent=2){
	$StringWriter = New-Object System.IO.StringWriter
	$XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter
	$XmlWriter.Formatting = "indented"
	$XmlWriter.Indentation = $Indent
	$xml.WriteContentTo($XmlWriter)
	$XmlWriter.Flush()
	$StringWriter.Flush()
	return $StringWriter.ToString()
}

##########################################################################
# IPv4 アドレス取得
##########################################################################
function GetMyIPv4Address(){
	# IPv4 アドレス
	[array]$IPv4Address = ipconfig | Select-String IPv4 | % { ($_ -split "\.:")[1].trim()} | % { $_ -replace "\(.+\)", "" } | ? { $_ -notmatch "^169.254" }

	# 複数 IPv4 アドレスを持っている場合は最初の有効な IP アドレスをセット
	if( $IPv4Address.Length -ne 0 ){
		$HostIPAddress = $IPv4Address[0]
	}
	else{
		# IPv4 アドレスが無い場合は N/A をセット
		$HostIPAddress = "N/A"
	}
	return $HostIPAddress
}

##########################################################################
# IPv6 アドレス取得
##########################################################################
function GetMyIPv6Address(){
	# IPv6 アドレス
	[array]$IPv6Address = ipconfig | Select-String IPv6 | % { ($_ -split "\.:")[1].trim()} | % { $_ -replace "\(.+\)", "" } | ? { $_ -notmatch "^fe80" }

	if( $IPv6Address.Length -ne 0 ){
		$HostIPAddress = $IPv6Address[0]
	}
	else{
		# IPv6 アドレスが無い場合は N/A をセット
		$HostIPAddress = "N/A"
	}

	return $HostIPAddress
}

##########################################################################
# Mail 用の FQDN セット
##########################################################################
function SetMyFQDN(){
	#  .NET Framework 4.0 以降の場合
	if($PSVersionTable.CLRVersion.Major -ge 4){
		# FQDN を求める
		$Data = nslookup $env:computername | Select-String "名前:"
		if( $Data -ne $null ){
			$Part = -split $Data
			$FQDN = $Part[1]
		}

		# FQDN が DNS に登録されているホストの場合
		if( $FQDN -ne $null ){
			# app.config を作成する
			$AppConfig = Join-Path $G_ScriptDir "app.config"
@"
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
	<system.net>
		<mailSettings>
			<smtp>
				<network
					clientDomain="$FQDN"
				/>
			</smtp>
		</mailSettings>
	</system.net>
</configuration>
"@ | set-content $AppConfig -Encoding UTF8

			# HELO 申告ホスト名に FQDN をセットする
			[AppDomain]::CurrentDomain.SetData("APP_CONFIG_FILE", $AppConfig)
			Add-Type -AssemblyName System.Configuration
		}
	}
}

####################################
# ヒア文字列を配列にする
####################################
function HereString2StringArray( $HereString ){
	$Temp = $HereString.Replace("`r","")
	$StringArray = $Temp.Split("`n")
	return $StringArray
}

##########################################################################
#
# Main
#
##########################################################################

Log "[INFO] ======= 処理開始 ======="

# メール送信用 FQDN セット
SetMyFQDN

# ホスト名
$HostName = hostname

$HostIPv4Address = GetMyIPv4Address
$HostIPv6Address = GetMyIPv6Address

# マシン情報
$Manufacturer = (Get-WmiObject Win32_BIOS).Manufacturer
$Model = (Get-WmiObject Win32_ComputerSystem).Model
$SerialNumber = (Get-WmiObject Win32_BIOS).SerialNumber
$OS = (Get-WmiObject Win32_OperatingSystem).Caption
$SP = (Get-WmiObject Win32_OperatingSystem).ServicePackMajorVersion
if( $SP -ne 0 ){
	$OS += " SP" + $SP
}

# ヒア文字列から配列に変換
[array]$CheckEventLogNames = HereString2StringArray $C_CheckEventLogNames
[array]$SkipLogs = HereString2StringArray $C_SkipLogs
[array]$SkipError = HereString2StringArray $C_SkipError
[array]$TrapWarning = HereString2StringArray $C_TrapWarning
[array]$TrapInformation = HereString2StringArray $C_TrapInformation
[array]$CheckAppLogNames = HereString2StringArray $C_CheckAppLogNames
[array]$RcpTos = HereString2StringArray $C_RcpTos

# 前回の処理開始時刻を取得
if( Test-Path $C_GetTimeFile ){
	$StartTime = (Get-Content $C_GetTimeFile) -as [DateTime]
	if($StartTime -eq $null){
		# 正しく取れなかった時は所定時間前
		$StartTime = (Get-Date).AddMinutes(-$C_StartDelay)
	}
	else{
		# 所定時間より前の場合
		$TimeDiff = New-TimeSpan $StartTime (Get-Date)
		if( $TimeDiff.TotalMinutes -gt $C_StartDelay ){
			# 所定時間前
			$StartTime = (Get-Date).AddMinutes(-$C_StartDelay)
		}
	}
}
else{
	# 初めての時は所定時間前
	$StartTime = (Get-Date).AddMinutes(-$C_StartDelay)
}

### 従来のイベントログを処理
# ログ一覧取得
$Logs = Get-EventLog -list

# イベントログ名一覧にする
$LogNames = @()
foreach( $Log in $Logs ){
	# 処理対象ログ名
	$LogNames += $Log.Log
}

# 処理対象のログ名セット
# 指定ログのみチェックの時
$TergetLogNames = @()
if( $C_CheckSelectEventLog ){
	# 正しいイベントログ名かのチェック
	foreach( $CheckEventLogName in $CheckEventLogNames ){
		if( $LogNames -contains $CheckEventLogName ){
			$TergetLogNames += $CheckEventLogName
		}
		else{
			Log "[ERROR] $CheckEventLogName はイベントログではない"
		}
	}
}
# 全てのイベントログをチェックする
else{
	$TergetLogNames = $LogNames
}

$ProcessedLog = @() # WinEvent での処理スキップ用配列

# 実行時刻の記録
(Get-Date) -as [String] | Set-Content $C_GetTimeFile
Log "[INFO] イベントログ 収集開始時刻 : $StartTime"


foreach( $TergetLogName in $TergetLogNames ){
	# WinEvent での処理スキップ用配列作成
	$ProcessedLog += $TergetLogName

	Log "[INFO] $TergetLogName のエラーイベントログ収集開始"

	# スキップ対象外のログ
	if( -not ($SkipLogs -contains $TergetLogName) ){
		$EventLogs = ""
		# イベントログ取得
		$EventLogs = Get-EventLog -LogName $TergetLogName -After $StartTime -ErrorAction SilentlyContinue

		# ログがあった場合
		if( $EventLogs.Length -gt 0 ){
			# ソースとIDでグループ化
			$EventLogSams = $EventLogs | Group -Property Source,EventID

			# サマリ単位でチェック
			foreach( $EventLogSam in $EventLogSams ){
				#イベントタイプの取得
				$EventType = $EventLogSam.Group[0].EntryType

				# ソース、IDの取得
				$Source = $EventLogSam.Name.split(",")[0].trim()
				$ID = $EventLogSam.Name.split(",")[1].trim()

				# サマリー数の取得
				$Count = $EventLogSam.Count

				# チェック用にイベントID加工
				$ChkEvent = $Source + " " + $ID

				Switch($EventType){
					"Error"{	# エラーの時
						if( $SkipError -contains $ChkEvent){
							# スキップ対象なのでスキップする
							$TrapEvent = $False
						}
						else{
							# トラップする
							$TrapEvent = $True
						}
					}

					"Warning"{ # 警告の時
						if( $TrapWarning -contains $ChkEvent){
							# トラップ対象なのでトラップする
							$TrapEvent = $True
						}
						else{
							# スキップする
							$TrapEvent = $False
						}
					}

					"Information"{ # 情報の時
						if( $TrapInformation -contains $ChkEvent){
							# トラップ対象なのでトラップする
							$TrapEvent = $True
						}
						else{
							# スキップする
							$TrapEvent = $False
						}
					}

					default { # 誤動作対策
							$ErrorMessage = "[Warning] " + $TergetLogName + " / " + $EventType + " / " + $ChkEvent
							Log $ErrorMessage
							$TrapEvent = $False
					}
				}

				if( $TrapEvent ){
					# トラップするイベントの時
					# イベント取得
					[array]$HitEventLogs = $EventLogs | ? {($_.Source -eq $Source) -and ($_.EventID -eq $ID) }

					$EventTime = $HitEventLogs[0].TimeGenerated
					$EventSource = $HitEventLogs[0].Source
					$EventID = $HitEventLogs[0].EventID
					$EventMessage = $HitEventLogs[0].Message
					$EventIndex = $HitEventLogs[0].Index

					$EventCount = $Count
					if($C_OutputEventXML){
						$WinEvent = Get-WinEvent -LogName $TergetLogName -ErrorAction SilentlyContinue | ? { (($_.ProviderName -eq $EventSource) -and ($_.RecordId -eq $EventIndex))}
						$EventXML = $WinEvent.ToXML()
						$EventXMLData = Format-XML $EventXML 2
					}
					else{
						$EventXMLData = ""
					}
					MailSend `
							$C_MSA `
							$C_MailFrom `
							$RcpTos `
							$C_ProjectName `
							$EventType `
							$Manufacturer `
							$Model `
							$SerialNumber `
							$OS `
							$HostName `
							$C_Alias `
							$C_ServerType `
							$HostIPv4Address `
							$HostIPv6Address `
							$TergetLogName `
							$EventTime `
							$EventSource `
							$EventID `
							$EventMessage `
							$EventCount `
							$EventXMLData
				}
				else{
					Log "[INFO] $TergetLogName / $EventType / $ChkEvent は検出対象外のためスルー"
				}
			}
		}
		else{
			Log "[INFO] $TergetLogName にエラーログは存在しない"
		}
	}
	else{
		Log "[INFO] $TergetLogName は処理対象外なのでスキップ"
	}
}

### アプリケーションとサービスログ指定があればチェックする
if( ($CheckAppLogNames.Length -ne 0) -and ($CheckAppLogNames -ne $null ) ){
	# 処理対象のログ一覧取得
	$Logs = @()
	foreach( $CheckAppLogName in $CheckAppLogNames ){
		$Logs += Get-WinEvent -ListLog $CheckAppLogName -ErrorAction SilentlyContinue
	}

	foreach( $Log in $Logs ){
		# 処理対象ログ名
		$TergetLogName = $Log.LogName

		Log "[INFO] $TergetLogName のエラーイベントログ収集開始"

		# スキップログ
		if( -not ($SkipLogs -contains $TergetLogName) ){
			# 処理済みのログ
			if( -not ($ProcessedLog -contains $TergetLogName) ){
				$EventLogs = ""
				# イベントログ取得
				$EventLogs = Get-WinEvent -LogName $TergetLogName -ErrorAction SilentlyContinue | ? {$_.TimeCreated -ge $StartTime}

				# ログがあった場合
				if( $EventLogs.Length -gt 0 ){
					# ソースとIDでグループ化
					$EventLogSams = $EventLogs | Group -Property ProviderName,Id

					# サマリ単位でチェック
					foreach( $EventLogSam in $EventLogSams ){
						#イベントタイプの取得
						$EventLevel = $EventLogSam.Group[0].Level

						# ソース、IDの取得
						$Source = $EventLogSam.Name.split(",")[0].trim()
						$ID = $EventLogSam.Name.split(",")[1].trim()

						# サマリー数の取得
						$Count = $EventLogSam.Count

						# チェック用にイベントID加工
						$ChkEvent = $Source + " " + $ID

						Switch($EventLevel){
							1 { # 重大の時
								$EventType = "Fail"
								$TrapEvent = $True
							}
							2 {	# エラーの時
								$EventType = "Error"
								if( $SkipError -contains $ChkEvent){
									# スキップするエラー
									$TrapEvent = $False
								}
								else{
									# トラップするエラー
									$TrapEvent = $True
								}
							}

							3 { # 警告の時
								$EventType = "Warning"
								if( $TrapWarning -contains $ChkEvent){
									# トラップする警告
									$TrapEvent = $True
								}
								else{
									# スキップする警告
									$TrapEvent = $False
								}
							}

							4 { # 情報の時
								$EventType = "Information"
								if( $TrapInformation -contains $ChkEvent){
									# トラップする情報
									$TrapEvent = $True
								}
								else{
									# スキップする情報
									$TrapEvent = $False
								}
							}

							default { # 誤動作対策
									$ErrorMessage = "[Warning] " + $TergetLogName + " / " + $EventLevel + " / " + $ChkEvent
									Log $ErrorMessage
									$TrapEvent = $False
							}
						}

						if( $TrapEvent -eq $True ){
							# イベント取得
							[array]$HitEventLogs = $EventLogs | ? {($_.ProviderName -eq $Source) -and ($_.Id -eq $ID) }

							$EventTime = $HitEventLogs[0].TimeCreated
							$EventSource = $HitEventLogs[0].ProviderName
							$EventID = $HitEventLogs[0].Id
							$EventMessage = $HitEventLogs[0].Message
							$EventXML = $HitEventLogs[0].ToXML()

							$EventCount = $Count
							$EventXMLData = Format-XML $EventXML 2
							MailSend `
									$C_MSA `
									$C_MailFrom `
									$RcpTos `
									$C_ProjectName `
									$EventType `
									$Manufacturer `
									$Model `
									$SerialNumber `
									$OS `
									$HostName `
									$C_Alias `
									$C_ServerType `
									$HostIPv4Address `
									$HostIPv6Address `
									$TergetLogName `
									$EventTime `
									$EventSource `
									$EventID `
									$EventMessage `
									$EventCount `
									$EventXMLData
						}
						else{
							Log "[INFO] $TergetLogName / $EventType / $ChkEvent は検出対象外のためスルー"
						}
					}
				}
				else{
					Log "[INFO] $TergetLogName にエラーログは存在しない"
				}
			}
			else{
				Log "[INFO] $TergetLogName は処理済なのでスキップ"
			}
		}
		else{
			Log "[INFO] $TergetLogName は処理対象外なのでスキップ"
		}
	}
}

Log "[INFO] ======= 処理終了 ======="
