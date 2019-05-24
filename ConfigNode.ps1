######################################################
#
# ノード別設定
#
######################################################

### 必ず設定する項目 ###
# プロジェクト名
$C_ProjectName = "### プロジェクト名(大分類に使ってください) ###"

# サーバーの役割
$C_ServerType = "### Hyper-V とか File Server とか ###"

# サーバーの別名
$C_Alias = "### 別名があれば ###"


# メールサーバー
$C_MSA = "### メールサーバー FQDN or IP アドレス ###"

# チェックするアプリケーションとサービスログ
<#
役割別設定例

	Hyper-V
		Microsoft-Windows-Hyper-V-*

	AD DS
		DFS Replication
		Directory Service
		DNS Server

	DNS
		DNS Server
#>
$C_CheckAppLogNames = @"
"@
