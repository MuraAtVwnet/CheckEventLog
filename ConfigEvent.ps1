##########################################################################
#
# イベントログチェック
#  環境設定(イベントトラップ/スルー)
#
##########################################################################

### 必要に応じて設定変更する項目 ###

# スルーするエラーイベント(ソース イベントID)
$C_SkipError = @"
OpsMgr Connector 21006
VDS Basic Provider 1
VSS 8193
VSS 7001
volsnap 27
Iphlpsvc 4202
Schannel 36882
Schannel 36888
Schannel 36887
Schannel 36874
Defrag 257
Microsoft-Windows-Defrag 257
Perflib 1008
UmrdpService 1111
TermDD 56
TermDD 50
TermService 1061
DCOM 10016
ESENT 489
MSSQLSERVER 14420
MSSQLSERVER 14421
MSSQLSERVER 17806
MSSQLSERVER 18204
SNMP 1500
DCOM 10006
DCOM 10009
DCOM 10010
Microsoft-Windows-CAPI2 4107
Microsoft-Windows-FilterManager 3
PerfNet 2004
"@

# トラップする警告イベント(ソース イベントID)
$C_TrapWarning = @"
ixgbn 27
e1rexpress 27
Server Administrator 2094
Server Administrator 2405
"@

# トラップする情報イベント(ソース イベントID)
$C_TrapInformation = @"
Server Administrator 2095
"@
