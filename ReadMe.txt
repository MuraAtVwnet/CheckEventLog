■ 機能
    10分ごとにイベントログを読んで、通知対象のイベントがあればメールします。

■ 動作環境
    以下環境での稼働実績があります。
        Windows Server 2008 R2
        Windows Server 2012
        Windows Server 2012 R2
        Windows Server 2016 TP5

■ インストール方法
    適当なフォルダーに全てのファイルをコピー

    ConfigCommon.ps1 の「### 必ず設定する項目 ###」を設定

    ConfigNode.ps1 の「### 必ず設定する項目 ###」を設定
        「チェックするアプリケーションとサービスログ」を指定すると、アプリケーションログをチェックします。
        必要に応じてサーバー用のログをセットしてください。(Hyper-V/AD DS/DNSの場合は、役割別設定例を設定すれば OK

    管理権限で Install.ps1 を実行

■ 動作確認
    TestEvent.ps1 を管理権限で実行すると、次のチェック時にメールが送信される

■ アンインストール方法
    管理権限で Uninstall.ps1 を実行
    全てのファイルを削除

■ 監視動作
    CheckEventLog.ps1
        監視スクリプト本体

    イベント別動作制御は ConfigEvent.ps1 で設定する

    エラー
        基本全部通知
        スルーイベント指定

    警告
        基本スルー
        通知イベント指定

    情報
        基本スルー
        通知イベント指定

■ ログクリーンナップ
    RemoveExecLog.ps1
        保存期間(5日)を過ぎた実行ログ(*.log)を削除

■ 展開補助機能
    Install.ps1
        スケジュール登録

    Uninstall.ps1
        スケジュール削除

    TestEvent.ps1
        テスト用イベントログ記録

■ 設定情報
    共通設定
        ConfigCommon.ps1
            全体共通設定

        ConfigEvent.ps1
            スルー/検出するイベント

    ノード固有設定
            ConfigNode.ps1

■ ファイル & ディレクトリ構造
    配置先\
        CheckEventLog.ps1
            イベントログ監視本体
        RemoveExecLog.ps1
            保存期間切れ実行ログ削除
        GetDate.dat
            前回実行時刻

        Install.ps1
            イベントログ監視登録
        Uninstall.ps1
            イベントログ監視削除
        TestEvent.ps1
            テスト用イベントログ記録

        ConfigCommon.ps1
            共通設定
        ConfigNode.ps1
            ノード設定
        ConfigEvent.ps1
            イベントのスルー/検出設定

        Log\
            実行ログ

■ メールに記載されている情報

    ・タイトル
        ConfigNode.ps1 の設定が表示されている項目
            【】           : プロジェクト名
            ()             :   サーバーの役割

        対象の情報
            xxxx           : hostname
            xxxx/9999      : イベントソース/イベントID

    ・本文
        ConfigNode.ps1 の設定が表示されている項目
            Project Name   : プロジェクト名
            Alias          : サーバーの別名
            Server Type    : サーバーの役割

        対象の情報
            ( 99 件)       : 検出した同じイベント数
            Status         : エラーの種別
            Host Name      : ホスト名
            IPv4 Address   : IPv4 アドレス(リンクローカルは含まず)
            IPv6 Address   : IPv6 アドレス(リンクローカルは含まず)
            Manufacturer   : WMI から得たメーカー名
            Model          : WMI から得たモデル名
            Serial Number  : WMI から得たシリアル番号(Dell だと Service TAG)
            OS             : OS とサービスパック
            Log Name       : 検出したログ名
            Generated Time : イベントが検出された時刻
            Event Source   : イベントソース名
            Event ID       : イベントID
            Message        : イベントログメッセージ
            XML            : イベントログの XML 情報

■ イベントログの検出調整

    特定エラーイベントを検出しないようにする場合
        「Event Source」 と 「Event ID」を ConfigEvent.ps1 の「スルーするエラーイベント」に追加します。

    特定の警告イベントを検出するようにする
        「Event Source」 と 「Event ID」を ConfigEvent.ps1 の「トラップする警告イベント」に追加します。

        イベントソースとイベントIDは、イベントビューアで「詳細」タブを開き、System を展開たときに表示される、「Provider」と「EventID」です。
            EventLog_001.png

    特定の情報イベントを検出するようにする
        警告と同様に「トラップする情報イベント」に「Event Source」 と 「Event ID」を追加します。

    Dell Server で運用していたので、Dell の Server Administrator イベントを検出するようにしています。(Dell 以外でもそのまま運用して実害無し)

    他メーカーの管理ツールのイベントを検出する対象にする場合は、適宜調整してください。

■ 最新版
    最新版以下で公開しています

    PowerShell でイベントログ監視
    http://www.vwnet.jp/Windows/PowerShell/EventLogMonitoring.htm

■ 更新履歴
    2016/08/27  1.00 公開用
    2016/08/29  1.01 Install.ps1 / Uninstall.ps1 が失敗する不具合対応
                     XML が変なところに入る Bug 修正
                     (公開用修正時の漏れでした orz)
    2016/09/03  1.02 RemoveExecLog.ps1 が失敗する不具合対応
