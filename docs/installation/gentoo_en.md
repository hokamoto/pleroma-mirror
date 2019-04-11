# Installing on Gentoo GNU/Linux
## Installation

This guide will assume that you have administrative rights, either as root or a user with [sudo permissions](https://wiki.gentoo.org/wiki/Sudo). Lines that begin with `#` indicate that they should be run as the superuser. Lines using `$` should be run as the indicated user, e.g. `pleroma$` should be run as the `pleroma` user.

### Configuring your hostname (optional)

If you would like your prompt to permanently include your host/domain, change `/etc/conf.d/hostname` to your hostname. You can reboot or use the `hostname` command to make immediate changes.

### Your make.conf and USE flags

Edit `/etc/portage/make.conf` and add `odbc` and `uuid` to your USE flags. If this is a new installation and there are not yet USE flags, add

`USE="odbc uuid"`

to the end of your `make.conf`. If you require any special compilation flags or would like to set up remote builds, now is the time to do so.

Be sure that your CFLAGS and MAKEOPTS make sense for the platform you are using. It is not recommended to use above `-O2` or risky optimization flags for a production server.

If you would rather `odbc` was only attached to the required packages, add the line `dev-lang/elixir odbc` to a file in `/etc/portage/package.use/`. `uuid` is a required extension for PostgreSQL, and as such can be added to `package.use` with the line `dev-db/postgresql uuid`.

### Required ebuilds

* `dev-db/postgresql`
* `dev-lang/elixir`
* `dev-vcs/git`

Note that `dev-db/unixODBC` will be installed as a dependency as long as you have the odbc global USE flag or set as a package USE flag for `dev-lang/elixir`.

#### Optional packages used in this guide

* `www-servers/nginx` (preferred, example configs for other reverse proxies can be found in the repo)
* `app-crypt/certbot` (or any other ACME client for Let’s Encrypt certificates)

### Prepare the system

* First ensure that you have the latest copy of the portage ebuilds if you have not synced them yet:

```shell
 # emerge --sync
```

* Emerge all required the required and suggested software in one go:

```shell
 # emerge --ask dev-db/postgresql dev-lang/elixir dev-vcs/git www-servers/nginx app-crypt/certbot
```

If you would not like to install the optional packages, remove them from this line. 

### Install PostgreSQL

[Gentoo  Wiki article](https://wiki.gentoo.org/wiki/PostgreSQL) as well as [PostgreSQL QuickStart](https://wiki.gentoo.org/wiki/PostgreSQL/QuickStart)

* Install postgresql if you have not done so already:

```shell
 # emerge --ask dev-db/postgresql
```

Ensure that `/etc/conf.d/postgresql-11` has the encoding you want (it defaults to UTF8 which is probably what you want) and make any adjustments to the data directory if you find it necessary.

* Initialize the database cluster

The output from emerging postgresql should give you a command for initializing the postgres database. Run that.

```shell
 # emerge --config =dev-db/postgresql-11.2
```

* Start postgres and enable the system service
 
Start postgres

```shell
 # /etc/init.d/postgresql-11 start
```

Add postgres to the default runlevel

```shell
 # rc-update add postgresql-11 default
 ```
 
### A note on licenses, the AGPL, and deployment procedures

If you do not plan to make any modifications to your Pleroma instance, cloning directly from the main repo will get you what you need. However, if you plan on doing any contributions to upstream development, making changes or modifications to your instance, making custom themes, or want to play around--and let's be honest here, if you're using Gentoo that is most likely you--you will save yourself a lot of headache later if you take the time right now to fork the Pleroma repo and use that in the following section.

Not only does this make it much easier to deploy changes you make, as you can commit and pull from upstream and all that good stuff from the comfort of your local machine then simply `git pull` on your instance server when you're ready to deploy, it also ensures you are compliant with the Affero General Public Licence that Pleroma is licenced under, which stipulates that all network services provided with modified AGPL code must publish their changes on a publicly available internet service and for free. It also makes it much easier to ask for help from and provide help to your fellow Pleroma admins if your public repo always reflects what you are running because it is part of your deployment procedure.

### Install PleromaBE

* Add a new system user for the Pleroma service and set up default directories:

Remove `,wheel` if you do not want this user to be able to use `sudo`, however note that being able to `sudo` as the `pleroma` user will make finishing the insallation and common maintenence tasks somewhat easier:

```shell
 # useradd -m -G users,wheel -s /bin/bash pleroma
```

Optional: if you would like to be able to use `sudo` as the `pleroma` user without setting a password, edit `/etc/sudoers` and uncomment the line near the bottom so it says `%wheel ALL=(ALL) NOPASSWD: ALL` without the preceeding `#`. If you would prefer a different setup, refer to instructions in `/etc/suoders` or check [the Gentoo sudo guide](https://wiki.gentoo.org/wiki/Sudo).

**Note**: To execute a single command as the Pleroma system user, use `sudo -Hu pleroma command`. You can also switch to a shell by using `sudo -Hu pleroma $SHELL`. If you don't have or want `sudo` or would like to use the system as the `pleroma` user for instance maintenance tasks, you can simply use `su - pleroma` to switch to the `pleroma` user.

* Git clone the PleromaBE repository and make the Pleroma user the owner of the directory:

It is highly recommended you use your own fork for the `https://path/to/repo` part below, however if you foolishly decide to forego using your own fork, the primaray repo `https://git.pleroma.social/pleroma/pleroma` will work here.

```shell
 pleroma$ cd ~
 pleroma$ git clone https://path/to/repo
```

* Change to the new directory:

```shell
pleroma$ cd ~/pleroma
```

* Install the dependencies for Pleroma and answer with `yes` if it asks you to install `Hex`:

```shell
pleroma$ sudo -Hu pleroma mix deps.get
```

* Generate the configuration:

```shell
pleroma$ sudo -Hu pleroma mix pleroma.instance gen
```

  * Answer with `yes` if it asks you to install `rebar3`.

  * This part precompiles some parts of Pleroma, so it might take a few moments

  * After that it will ask you a few questions about your instance and generates a configuration file in `config/generated_config.exs`.

  * Spend some time with `generated_config.exs` to ensure that everything is in order. If you plan on using an S3-compatible service to store your local images, that can be done here. (`prod.secret.exs` for productive instance, `dev.secret.exs` for development instances):

```shell
pleroma$ mv config/generated_config.exs config/prod.secret.exs
```

* The previous command creates also the file `config/setup_db.psql`, with which you can create the database:

```shell
pleroma$ sudo -Hu postgres psql -f config/setup_db.psql
```

* Now run the database migration:

```shell
sudo -Hu pleroma MIX_ENV=prod mix ecto.migrate
```

* Now you can start Pleroma already

```shell
sudo -Hu pleroma MIX_ENV=prod mix phx.server
```

### Finalize installation

If you want to open your newly installed instance to the world, you should run nginx or some other webserver/proxy in front of Pleroma and you should consider to create a systemd service file for Pleroma.

#### Nginx

* Install nginx, if not already done:

```shell
sudo pacman -S nginx
```

* Create directories for available and enabled sites:

```shell
sudo mkdir -p /etc/nginx/sites-{available,enabled}
```

* Append the following line at the end of the `http` block in `/etc/nginx/nginx.conf`:

```Nginx
include sites-enabled/*;
```

* Setup your SSL cert, using your method of choice or certbot. If using certbot, first install it:

```shell
sudo pacman -S certbot certbot-nginx
```

and then set it up:

```shell
sudo mkdir -p /var/lib/letsencrypt/
sudo certbot certonly --email <your@emailaddress> -d <yourdomain> --standalone
```

If that doesn’t work, make sure, that nginx is not already running. If it still doesn’t work, try setting up nginx first (change ssl “on” to “off” and try again).

---

* Copy the example nginx configuration and activate it:

```shell
sudo cp /opt/pleroma/installation/pleroma.nginx /etc/nginx/sites-available/pleroma.nginx
sudo ln -s /etc/nginx/sites-available/pleroma.nginx /etc/nginx/sites-enabled/pleroma.nginx
```

* Before starting nginx edit the configuration and change it to your needs (e.g. change servername, change cert paths)
* Enable and start nginx:

```shell
sudo systemctl enable --now nginx.service
```

If you need to renew the certificate in the future, uncomment the relevant location block in the nginx config and run:

```shell
sudo certbot certonly --email <your@emailaddress> -d <yourdomain> --webroot -w /var/lib/letsencrypt/
```

#### Other webserver/proxies

You can find example configurations for them in `/opt/pleroma/installation/`.

#### Systemd service

* Copy example service file

```shell
sudo cp /opt/pleroma/installation/pleroma.service /etc/systemd/system/pleroma.service
```

* Edit the service file and make sure that all paths fit your installation
* Enable and start `pleroma.service`:

```shell
sudo systemctl enable --now pleroma.service
```

#### Create your first user

If your instance is up and running, you can create your first user with administrative rights with the following task:

```shell
sudo -Hu pleroma MIX_ENV=prod mix pleroma.user new <username> <your@emailaddress> --admin
```

#### Further reading

* [Admin tasks](Admin tasks)
* [Backup your instance](Backup-your-instance)
* [Configuration tips](General tips for customizing pleroma fe)
* [Hardening your instance](Hardening-your-instance)
* [How to activate mediaproxy](How-to-activate-mediaproxy)
* [Small Pleroma-FE customizations](Small customizations)
* [Updating your instance](Updating-your-instance)

## Questions

Questions about the installation or didn’t it work as it should be, ask in [#pleroma:matrix.org](https://matrix.heldscal.la/#/room/#freenode_#pleroma:matrix.org) or IRC Channel **#pleroma** on **Freenode**.
