# Installing on Debian Based Distributions
## Installation

This guide is a step-by-step installation guide for Debian-based distributions, it assumes a setup similar to Debian Stretch.
Commands starting with `#` should be launched as root, with `$` they should be launched as the `pleroma` user, with `%` they can be launched with any user on the machine, in case they need a specific user they’ll be prefixed with `username $`. It is recommended to keep the session until it changes of user or tells you to exit. See [[unix session management]] if you do not know how to do it.

### Required packages

* `postgresql` (9.6+, Ubuntu 16.04 comes with 9.5, you can get a newer version from <https://www.postgresql.org/download/linux/ubuntu/>
* `postgresql-contrib` (9.6+, same situtation as above)
* `elixir` (1.7+, Debian and Ubuntu ships old versions, install from <https://elixir-lang.org/install.html#unix-and-unix-like> or use [asdf](https://github.com/asdf-vm/asdf) as the pleroma user)
* `erlang-dev`
* `erlang-tools`
* `erlang-parsetools`
* `erlang-eldap`, if you want to enable ldap authenticator
* `erlang-ssh`
* `erlang-xmerl`
* `git`
* `build-essential`

#### Optional packages used in this guide

* `nginx` (preferred, example configs for other reverse proxies can be found in the repo)
* `certbot` (or any other ACME client for Let’s Encrypt certificates)

### Prepare the system

* First update the system, if not already done:

```shell
# apt update
# apt full-upgrade
# apt autoremove
# reboot
```

* Install some of the above mentioned programs:

```shell
# apt install git build-essential
```

* Add a new system user for the Pleroma service:

```shell
# useradd -r -m -d /var/lib/pleroma -U pleroma
```

### Install PostgreSQL

Following tutorial is for Ubuntu 16. For other platforms, see [PostgreSQL's official document](https://www.postgresql.org/download/linux/ubuntu/).

```shell
# nano /etc/apt/sources.list.d/pgdg.list
```

Write following code into the `pgdg.list`.

```
deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main
```

```shell
% wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
# apt update
# apt install postgresql postgresql-contrib
```

Check PostgreSQL's port number and version.

```shell
postgres $ psql -p 5432 -c 'SELECT version()'
```

If some versions of PostgreSQL are installed in your system, try sequential port numbers 5432, 5433, ..., while you get the version you want.

### Install Elixir and Erlang

* Download and add the Erlang repository:

```shell
% wget -P /tmp/ https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
# dpkg -i /tmp/erlang-solutions_1.0_all.deb
```

* Install Elixir and Erlang:

```shell
# apt update
# apt install elixir erlang-dev erlang-tools erlang-parsetools erlang-eldap erlang-xmerl erlang-ssh
```

### Install and Configure Pleroma

#### Get pleroma source code
```shell
$ cd
$ git clone -b master https://git.pleroma.social/pleroma/pleroma.git ~pleroma/pleroma
$ cd ~pleroma/pleroma
```

Note: The `master` branch was selected, you can switch to another one with `git checkout`. However, be aware almost all other branches are based on the `develop` branch (see [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/)), which usually contains database migrations not present in `master`, meaning that if you choose to switch from master you **can't** switch back until the next release.

#### Install Elixir dependencies
* Install the dependencies for Pleroma and answer with `Y` if it asks you to install `Hex`:

```shell
$ mix deps.get
```

If you get ``mix: command not found``, a workaround ``$ export PATH=$PATH:/usr/local/bin`` may help you.

#### Configuration
* Generate the configuration: ``mix pleroma.instance gen``
  * Answer with `Y` if it asks you to install `rebar3`.
  * This may take some time, because parts of pleroma get compiled first.
  * After that it will ask you a few questions about your instance and generates a configuration file in `config/generated_config.exs`.

* Check the configuration and if all looks right, copy it, so Pleroma will load it (`prod.secret.exs` for production instances, `dev.secret.exs` for development instances):

```shell
$ cp config/generated_config.exs config/prod.secret.exs
```

* If your PostgreSQL's port number is not 5432, add `port` record into `Pleroma.Repo` section in the `prod.secret.exs` and/or `dev.secret.exs`.

* The configuration generator also creates the file `config/setup_db.psql`, with which you can create the database:

```shell
postgres $ psql -U postgres -f config/setup_db.psql
```
Or sometimes following workaround may help you:

```shell
# cat ~pleroma/pleroma/config/setup_db.psql | sudo -Hu postgres psql -U postgres -f -
```

* Change to production mode and make the next `pleroma` sessions default to it:

```shell
$ export MIX_ENV=prod
$ echo MIX_ENV=prod > ~/.profile
```

* Now run the database migration:

```shell
$ mix ecto.migrate
```

* Create the admin account:

```shell
$ mix pleroma.user new <username> <your@emailaddress> --admin
```

* Now you can start Pleroma manually for tests:

```shell
$ mix phx.server
```

#### Daemonize
This one is for systems using sytemd, such as: ArchLinux, Debian derivatives, Gentoo with systemd, RedHat-based (ie. CentOS)

* Copy example service file

```shell
# cp ~pleroma/pleroma/installation/pleroma.service /etc/systemd/system/pleroma.service
```

* Edit the service file and make sure that all paths fit your installation. Especially `WorkingDirectory=/opt/pleroma` has to be `WorkingDirectory=/var/lib/pleroma/pleroma`.

* Enable and start `pleroma.service`:

```shell
# systemctl enable --now pleroma.service
```

### Install nginx

* Install nginx, if not already done:

```shell
# apt install nginx
```

* Setup your SSL cert, using your method of choice or certbot. If using certbot, first install it:

```shell
# apt install certbot
```

and then set it up:

```shell
# mkdir -p /var/lib/letsencrypt/
# systemctl stop nginx
# certbot certonly --email <your@emailaddress> -d <yourdomain> --standalone
# systemctl start nginx
--standalone
```

If that doesn’t work, make sure, that nginx is not already running. If it still doesn’t work, try setting up nginx first (change ssl “on” to “off” and try again).

---

* Copy the example nginx configuration and activate it:

```shell
# cp ~pleroma/pleroma/installation/pleroma.nginx /etc/nginx/sites-available
# ln -s /etc/nginx/sites-available/pleroma.nginx /etc/nginx/sites-enabled/pleroma.nginx
```

* Before starting nginx edit the configuration and change it to your needs (e.g. change servername, change cert paths)
* Enable and start nginx:

```shell
# systemctl enable --now nginx.service
```

If you need to renew the certificate in the future, uncomment the relevant location block in the nginx config and run:

```shell
# certbot certonly --email <your@emailaddress> -d <yourdomain> --webroot -w /var/lib/letsencrypt/
```

#### Workarounds for nginx

You can watch the nginx's log by ``# systemctl status nginx`` or ``# journalctl -u nginx`` commands.

If your nginx does not work, and claims following message, this is [nginx's known bug](https://bugs.launchpad.net/ubuntu/+source/nginx/+bug/1581864).

```
systemd[1]: nginx.service: Failed to read PID from file /run/nginx.pid: Invalid argument
```

Following workaround may helps you.

```shell
# mkdir /etc/systemd/system/nginx.service.d
# printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
# systemctl daemon-reload
# systemctl restart nginx
```

If your nginx still does not work, and claims following message, your nginx dose not know some of the modern cryptographic algorithms.

```
nginx[1431]: nginx: [emerg] Unknown curve name "X25519:prime256v1:secp384r1:secp521r1" (SSL:)
```

Edit `/etc/nginx/sites-available/pleroma.nginx` and just comment out `ssl_ecdh_curve X25519:prime256v1:secp384r1:secp521r1;`.

#### Other webserver/proxies

You can find example configurations for them in `/var/lib/pleroma/installation/`.

## Further reading

* <s>Admin tasks</s>
* [Backup your instance](backup.html)
* [Configuration tips](general-tips-for-customizing-pleroma-fe.html)
* [Hardening your instance](hardening.html)
* [How to activate mediaproxy](howto_mediaproxy.html)
* [Small Pleroma-FE customizations](small_customizations.html)
* [Updating your instance](updating.html)

## Support & Questions

For support or questions please ask in the chatroom, available via IRC at `#pleroma` on [Freenode](https://freenode.net/) and via [Matrix on `#freenode_#pleroma:matrix.org`](https://matrix.heldscal.la/#/room/#freenode_#pleroma:matrix.org).

