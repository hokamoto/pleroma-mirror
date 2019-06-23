# Debianベースのディストリビューションにインストールする
## 日本語訳について

この記事は [Installing on Debian based distributions](debian_based_en.html) の日本語訳です。何かがおかしいと思ったら、原文を見てください。

## インストール

このガイドはステップ・バイ・ステップのインストールガイドです。Debianベースのディストリビューション、特にDebian Stretchを仮定しています。

コマンドが `#` で始まるならば、ルートで実行してください。コマンドが `$` で始まるならば、`pleroma` ユーザーで実行してください。コマンドが `%` で始まるならば、特にユーザーの指定はありません。これら以外に特にユーザーの指定が必要なときは `username $` と表記します。

ユーザーを切り替えるときか、exit するよう指示されたときを除いては、セッションを維持してください。

### 必要なパッケージ

* `postgresql` (9.6以上。Ubuntu 16.04のPostgreSQLは9.5なので、[新しいバージョンを取得する](https://www.postgresql.org/download/linux/ubuntu/)必要がある。)
* `postgresql-contrib` (9.6以上。同上。)
* `elixir` (1.7以上。[DebianとUbuntuのパッケージは古いので、ここからインストールすること](https://elixir-lang.org/install.html#unix-and-unix-like)。または、[asdf](https://github.com/asdf-vm/asdf)をpleromaユーザーで使うこと。)
* `erlang-dev`
* `erlang-tools`
* `erlang-parsetools`
* `erlang-eldap`
* `erlang-xmerl`
* `erlang-ssh`
* `git`
* `build-essential`

#### オプションのパッケージ

* `nginx` (推奨。他のリバースプロクシの設定の雛形も用意されている。)
* `certbot` (または他のACMEクライアント。)

### システムを準備する

* まずシステムをアップデートしてください。

```shell
# apt update
# apt full-upgrade
# apt autoremove
# reboot
```

* 必要なソフトウェアの一部をインストールします。

```shell
# apt install git build-essential
```

* 新しいユーザーを作成します。

```shell
# useradd -r -m -d /var/lib/pleroma -U pleroma
```

### PostgreSQLをインストールします

以下の例はUbuntu 16です。他のプラットフォームの説明は [PostgreSQLのウェブサイト](https://www.postgresql.org/download/linux/ubuntu/) にあります。

```shell
# nano /etc/apt/sources.list.d/pgdg.list
```

`pgdg.list` に以下のコードを入力します。

```
deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main
```

```shell
% wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
# apt update
# apt install postgresql postgresql-contrib
```

PostgreSQLのポート番号とバージョンを確認します。

```shell
postgres $ psql -p 5432 -c 'SELECT version()'
```

システムに複数のバージョンのPostgreSQLがインストールされているならば、希望するバージョンが得られるまで、ポート番号を5432から順に試してください。

### ElixirとErlangをインストールします

* Erlangのリポジトリをダウンロードおよび追加します。

```shell
% wget -P /tmp/ https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
# dpkg -i /tmp/erlang-solutions_1.0_all.deb
```

* ElixirとErlangをインストールします

```shell
# apt update
# apt install elixir erlang-dev erlang-tools erlang-parsetools erlang-eldap erlang-xmerl erlang-ssh
```

### Pleromaのインストールとコンフィギュレーション

#### Pleromaのソースコードを取得する
```shell
$ git clone -b master https://git.pleroma.social/pleroma/pleroma ~pleroma/pleroma
$ cd ~pleroma/pleroma
```

**注意** いま `master` ブランチが選択されており、`git checkout` で別のブランチに切り替えることができます。しかし、気を付けるべきことがあり、他のほとんどのブランチは `develop` ブランチから派生しています。([GitFlow](https://nvie.com/posts/a-successful-git-branching-model/) を見るとよい。) `develop` とそこから派生したブランチは、データベースのミグレーションを先行して行っており、そのミグレーションは `master` ブランチには反映されていないことがあります。つまり、`master` から別のブランチに切り替えたら、`master` に戻ってくることはおそらく不可能だろうということです。

#### Elixirの依存をインストールする
* Pleromaのための依存をインストールします。`Hex` をインストールするか聞かれたら、`Y` と回答してください。

```shell
$ mix deps.get
```

#### コンフィギュレーション
* コンフィギュレーションを生成する: ``mix pleroma.instance gen``
  * `rebar3` をインストールするか聞かれたら、`Y` と回答してください。
  * これには時間がかかります。Pleromaをコンパイルするためです。
  * あなたのインスタンスについていくつかの質問があります。コンフィギュレーションファイルが `config/generated_config.exs` に生成されます。

* コンフィギュレーションが正しいかどうか、ファイルの内容を確認してください。もし問題なければ、コピーしてください。Pleromaが読み込むのはコピーのほうです。コピー先のファイル名は、プロダクションインスタンスであれば `prod.secret.exs`、開発インスタンスであれば `dev.secret.exs` です。

```shell
$ cp config/generated_config.exs config/prod.secret.exs
```

* PostgreSQLのポート番号が5432でなければ、コンフィギュレーションファイルの `Pleroma.Repo` セクションに `port` レコードを追加する必要があります。

* 先ほどのコンフィギュレーションジェネレーターは `config/setup_db.psql` というファイルも生成します。これを使ってデータベースを作ります:

```shell
postgres $ psql -U postgres -f config/setup_db.psql
```

* プロダクションモードに変更します。また、`pleroma` ユーザーのセッションが常にプロダクションモードになるようにします。

```shell
$ export MIX_ENV=prod
$ echo MIX_ENV=prod > ~/.profile
```

* ベータベースのミグレーションを実行します。

```shell
$ mix ecto.migrate
```

* 管理者アカウントを作成します。

```shell
$ mix pleroma.user new <username> <your@emailaddress> --admin
```

* ここまで来れば、Pleromaを手動で起動することができます。

```shell
$ mix phx.server
```

#### デーモンにする
この節はsystemdを使うシステムのためのものです。ArchLinux、Debianの子孫たち、Gentoo with systemd、RedHatの子孫たち (CentOSなど) がそうです。

* サービスファイルの例をコピーしてください。

```shell
# cp ~pleroma/pleroma/installation/pleroma.service /etc/systemd/system/pleroma.service
```

* このサービスファイルの内容を編集して、すべてのパスが正しいことを確認してください。特に `WorkingDirectory=/opt/pleroma` は `WorkingDirectory=/var/lib/pleroma/pleroma` に訂正すべきです。

* `pleroma.service` サービスをイネーブルおよびスタートします。

```shell
# systemctl enable --now pleroma.service
```

### Nginxをインストールします

* Nginxをインストールします。

```shell
# apt install nginx
```

* SSLをセットアップします。certbotでよければ、まずそれをインストールします。

```shell
# apt install certbot
```

certbotをセットアップします。

```shell
# mkdir -p /var/lib/letsencrypt/
# systemctl stop nginx
# certbot certonly --email <your@emailaddress> -d <yourdomain> --standalone
# systemctl start nginx
```

もしうまくいかないならば、nginxが動作していないことを確認してください。それでもうまくいかないならば、先にnginxを設定 (ssl "on" を "off" に変える) してから再試行してください。

---

* nginxコンフィギュレーションの例をコピーおよびアクティベートします。

```shell
# cp ~pleroma/pleroma/installation/pleroma.nginx /etc/nginx/sites-available
# ln -s /etc/nginx/sites-available/pleroma.nginx /etc/nginx/sites-enabled/pleroma.nginx
```

* nginxを起動する前に、コンフィギュレーションを編集してください。例えば、サーバー名、証明書のパスなどを変更する必要があります。

* nginxをイネーブルおよび起動します。

```shell
# systemctl enable --now nginx.service
```
もし未来に証明書を延長する必要があるならば、nginxのコンフィグのリリバント・ロケーション・ブロックをアンコメントして、以下を実行してください。

```shell
# certbot certonly --email <your@emailaddress> -d <yourdomain> --webroot -w /var/lib/letsencrypt/
```

#### nginxのワークアラウンド

nginxのログは ``# systemctl status nginx`` または ``# journalctl -u nginx`` で見ることができます。

nginxが動いておらず、以下のエラーメッセージが見えているならば、[nginxの既知のバグ](https://bugs.launchpad.net/ubuntu/+source/nginx/+bug/1581864) を踏んでいます。

```
systemd[1]: nginx.service: Failed to read PID from file /run/nginx.pid: Invalid argument
```

以下のワークアラウンドがあります。

```shell
# mkdir /etc/systemd/system/nginx.service.d
# printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
# systemctl daemon-reload
# systemctl restart nginx
```

nginxが動いておらず、以下のエラーメッセージが見えているならば、nginxがモダンな楕円曲線に対応していません。

```
nginx[1431]: nginx: [emerg] Unknown curve name "X25519:prime256v1:secp384r1:secp521r1" (SSL:)
```

`/etc/nginx/sites-available/pleroma.nginx` を編集し、`ssl_ecdh_curve X25519:prime256v1:secp384r1:secp521r1;` という行をコメントアウトしてください。

#### 他のウェブサーバーとプロクシ

他のコンフィグレーションの例は `/var/lib/pleroma/installation/` にあります。

## カスタマイズとメンテナンス

* <s>Admin tasks</s>
* [Backup your instance](backup.html)
* [Configuration tips](general-tips-for-customizing-pleroma-fe.html)
* [Hardening your instance](hardening.html)
* [How to activate mediaproxy](howto_mediaproxy.html)
* [Small Pleroma-FE customizations](small_customizations.html)
* [Updating your instance](updating.html)

## 質問ある？

何か質問があれば、以下のチャットルームに来てください。IRCは [Freenode](https://freenode.net/) の `#pleroma` チャンネルです。[Matrix on `#freenode_#pleroma:matrix.org`](https://matrix.heldscal.la/#/room/#freenode_#pleroma:matrix.org) もあります。

