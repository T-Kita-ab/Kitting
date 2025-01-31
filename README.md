# (Windows11)キッティングの自動化(改良中)

## 目的

会社の環境上クローニングやintuneを使ったイメージの展開が難しいため、無料でできる範囲でキッティングの自動化に挑戦しました。

## キッティング内容

 *ユーザー名 

 *パスワード

 *PC名

 *リモートデスクトップのON

 *アプリのサイレントインストール

 *エクスプローラーの拡張子表示(再起動後反映)

 *高速スタートアップの無効

 *タスクビューの無効化

 *複合機のスキャンデータを保存する共有フォルダの作成

 *タスクバーの設定

## 使用方法
事前にセットアップ用のアカウントを作成してからキッティングを開始します。


スクリプトを実行するとユーザー名、パスワード、PC名を問われるので入力します。入力後自動でスクリプトが走り新規作成したユーザーで再起動後にログインし、キッティングを行います。

1：powershellを右クリックで管理者として開きます。

2：デフォルトではスクリプトの実行ができないので以下のコマンドで制限を解除します。

```
get-executionpolicy remotesigned -f
```

3：kitting.ps1のフルパスをコピーして実行します。

```
"フルパス\kitting.ps1"
```
4：スクリプト起動後ユーザー名、パスワード名、PC名を入力します。

5：再起動後もスクリプトが走り、「終了しました」まで表示されたら完了です。

## 課題

* 自動化できていない項目がまだたくさんあります。Windows10から11になったことで一部自動化が難しいところがありますが、現在さらなる改良に努めています。

```
*未達成の項目

所属部署毎のwifi登録
デスクトップアイコンのピン留め
スタートのピン留め
スクリーンセーバーの設定
既定のアプリ
chromeの拡張機能(別のスクリプトで実行可能)
```

* 会社の環境の都合上クローニングでのイメージ展開やintuneは使用できないためpowershellで自動化を試みました。しかし、コーディングよりもwindows公式のsysprepやintuneを使った方が効率的にできるのではないかと思い、これらの検証が必要だと考えました。
