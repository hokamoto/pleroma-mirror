# Pleromaの入れ方
## 日本語訳について

この記事は [Installing on Debian based distributions](https://docs-develop.pleroma.social/debian_based_en.html) の日本語訳です。何かがおかしいと思ったら、原文を見てください。

## インストール

このガイドはDebian Stretchを仮定しています。Ubuntu 16.04でも可能です。また、あなたが管理者権限を持っていることが必要です。すなわち、rootになるか、または[sudoパーミッション](https://www.digitalocean.com/community/tutorials/how-to-add-delete-and-grant-sudo-privileges-to-users-on-a-debian-vps)が必要です。もし、この文書の手順をrootとして実行したいならば、行の先頭にある `sudo` を無視してください。ただし、`sudo -Hu pleroma` のような、別のユーザーになるためのsudoは、省略できません。この場合には、かわりに、`su <username> -s $SHELL -c 'command'` のような形式のコマンドが必要です。

### 必要なソフトウェア

* `postgresql` (9.6以上。Ubuntu 16.04のPostgreSQLは9.5なので、[新しいバージョンを取得する](https://www.postgresql.org/download/linux/ubuntu/)必要がある。)
* `postgresql-contrib` (9.6以上。同上。)
* `elixir` (1.5以上。[DebianとUbuntuのパッケージは古いので、ここからインストールすること](https://elixir-lang.org/install.html#unix-and-unix-like)。または、[asdf](https://github.com/asdf-vm/asdf)をpleromaユーザーで使うこと。)
* `erlang-dev`
* `erlang-tools`
* `erlang-parsetools`
* `erlang-eldap`
* `erlang-xmerl`
* `git`
* `build-essential`

#### オプションのパッケージ

* `nginx` (推奨。他のリバースプロクシの設定の雛形も用意されている。)
* `certbot` (または他のACMEクライアント。)

### システムを準備する

* まずシステムをアップデートしてください。

```shell
sudo apt update
sudo apt full-upgrade
```

* 必要なソフトウェアの一部をインストールします。

```shell
sudo apt install git build-essential postgresql postgresql-contrib
```

### ElixirとErlangをインストールします

* Erlangのリポジトリをダウンロードおよび追加します。

```shell
wget -P /tmp/ https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i /tmp/erlang-solutions_1.0_all.deb
```

* ElixirとErlangをインストールします。

```shell
sudo apt update
sudo apt install elixir erlang-dev erlang-parsetools erlang-xmerl erlang-tools
```

### Pleroma BE (バックエンド) をインストールします

* Pleromaサービスのための新しいシステムユーザーを作ります。

```shell
sudo useradd -r -s /bin/false -m -d /var/lib/pleroma -U pleroma
```

**注意**: 単独のコマンドをPleromaシステムユーザーとして実行するには `sudo -Hu pleroma command` を使ってください。または、`sudo -Hu pleroma $SHELL`　で、別のユーザーのシェルに切り替えることができます。もし `sudo` コマンドがない状況で同じことがしたいなら、rootユーザーになったうえで、`su -l pleroma -s $SHELL -c 'command'` または `su -l pleroma -s $SHELL` を使ってください。

*  PleromaBEのGitリポジトリをクローンします。また、そのディレクトリのオーナーをPleromaユーザーにします。

```shell
sudo mkdir -p /opt/pleroma
sudo chown -R pleroma:pleroma /opt/pleroma
sudo -Hu pleroma git clone https://git.pleroma.social/pleroma/pleroma /opt/pleroma
```

*  新しいディレクトリに移動します。

```shell
cd /opt/pleroma
```

* Pleromaが依存するパッケージをインストールします。`Hex` をインストールしてもよいか聞かれたら、`yes` を入力してください。

```shell
sudo -Hu pleroma mix deps.get
```

* コンフィギュレーションを生成します: `sudo -Hu pleroma mix pleroma.instance gen`
  * `rebar3` をインストールしてもよいか聞かれたら、`yes` を入力してください。
  * この処理には時間がかかります。まずPleromaがコンパイルされるためです。
  * あなたのインスタンスについて、いくつかの質問があります。その回答は `config/generated_config.exs` というコンフィギュレーションファイルに保存されます。

* コンフィギュレーションを確認して、もし問題なければ、ファイル名を変更してください。Pleromaはそのファイルをロードします。本番用インスタンスでは `prod.secret.exs`、開発用インスタンスでは `dev.secret.exs` が使われます。

```shell
mv config/{generated_config.exs,prod.secret.exs}
```

* これまでのコマンドで、すでに `config/setup_db.psql` というファイルが作られています。このファイルをもとに、データベースを作成します。

```shell
sudo -Hu postgres psql -f config/setup_db.psql
```

* そして、データベースのミグレーションを実行します。

```shell
sudo -Hu pleroma MIX_ENV=prod mix ecto.migrate
```

* Pleromaを起動できるようになりました。

```shell
sudo -Hu pleroma MIX_ENV=prod mix phx.server
```

### インストールを終わらせる

あなたの新しいインスタンスを世界に向けて公開するには、nginxまたは何らかのウェブサーバー (プロクシ) を使用する必要があります。また、Pleroma のためにシステムサービスファイルを作成する必要があります。

#### Nginx

* まだインストールしていないなら、nginxをインストールします。

```shell
sudo apt install nginx
```

* SSLをセットアップします。他の方法でもよいですが、ここではcertbotを説明します。certbotを使うならば、まずそれをインストールします。

```shell
sudo apt install certbot
```

そしてセットアップします。

```shell
sudo mkdir -p /var/lib/letsencrypt/
sudo certbot certonly --email <your@emailaddress> -d <yourdomain> --standalone
```

もしうまくいかないならば、nginxが動作していないことを確認してください。それでもうまくいかないならば、先にnginxを設定 (ssl "on" を "off" に変える) してから再試行してください。

---

* nginxコンフィギュレーションの例をコピーおよびアクティベートします。

```shell
sudo cp /opt/pleroma/installation/pleroma.nginx /etc/nginx/sites-available/pleroma.nginx
sudo ln -s /etc/nginx/sites-available/pleroma.nginx /etc/nginx/sites-enabled/pleroma.nginx
```

* nginxを起動する前に、コンフィギュレーションを編集してください。例えば、サーバー名、証明書のパスなどを変更する必要があります。

* nginxをイネーブルおよび起動します。

```shell
sudo systemctl enable --now nginx.service
```

もし未来に証明書を延長する必要があるならば、nginxのコンフィグのリリバント・ロケーション・ブロックをアンコメントして、以下を実行してください。

```shell
sudo certbot certonly --email <your@emailaddress> -d <yourdomain> --webroot -w /var/lib/letsencrypt/
```

#### 他のウェブサーバー／プロクシ

他のコンフィグレーションの例は `/opt/pleroma/installation/` にあります。

#### Systemd サービス

* サービスファイルの例をコピーします。

```shell
sudo cp /opt/pleroma/installation/pleroma.service /etc/systemd/system/pleroma.service
```

* サービスファイルを変更します。すべてのパスが正しいことを確認してください。
* `pleroma.service` をイネーブルおよび起動します。

```shell
sudo systemctl enable --now pleroma.service
```

#### 最初のユーザーを作る

あなたのインスタンスが動作しているならば、管理権限を持つ最初のユーザーを作ることができます。

```shell
sudo -Hu pleroma MIX_ENV=prod mix pleroma.user new <username> <your@emailaddress> --admin
```

#### 他の文書

* _Admin tasks_
* [Backup your instance](https://docs-develop.pleroma.social/backup.html)
* [Configuration tips](https://docs-develop.pleroma.social/general-tips-for-customizing-pleroma-fe.html)
* _Hardening your instance_
* [How to activate mediaproxy](https://docs-develop.pleroma.social/howto_mediaproxy.html)
* [Small Pleroma-FE customizations](https://docs-develop.pleroma.social/small_customizations.html)
* [Updating your instance](https://docs-develop.pleroma.social/updating.html)

## 質問ある？

インストールについて質問がある、もしくは、うまくいかないときは、以下のところで質問できます。

* [#pleroma:matrix.org](https://matrix.heldscal.la/#/room/#freenode_#pleroma:matrix.org)
* **[Freenode](https://freenode.net/)** の **#pleroma** IRCチャンネル
