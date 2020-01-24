# Configuring instance
You can configure your instance from admin interface. You need account with admin rights and little change in config file, which will allow settings configuration from database.

```elixir
config :pleroma, configurable_from_database: true
```

## How it works
Settings are stored in database and are applied in `runtime` after each change. Most of the settings take effect immediately, except some, which need instance reboot. These settings are needed in `compile time`, that's why these settings are duplicated to the file.

File with duplicated settings is located in `config/{env}.for_reboot.exs` if pleroma is runned from source. For prod env it will be `config/prod.for_reboot.exs`.

For releases: `/etc/pleroma/prod.for_reboot.exs` or `PLEROMA_CONFIG_PATH/prod.for_reboot.exs`.

## How to set it up
You need to migrate your existing settings to the database. This task will migrate only added by user settings.
For example you add settings to `prod.secret.exs` file, only these settings will be migrated to the database. For releases path will be `/etc/pleroma/config.exs` or `PLEROMA_CONFIG_PATH`.
You can do this with mix task (all config files will remain untouched):

```sh tab="OTP"
 ./bin/pleroma_ctl config migrate_to_db
```

```sh tab="From Source"
mix pleroma.config migrate_to_db
```

Now you can change settings in admin interface. After each save, `compile time` settings from database are duplicated to the `config/{env}.for_reboot.exs` file.

<span style="color:red">**ATTENTION**</span>

**<span style="color:red">Be careful while changing the settings. Every inaccurate configuration change can break federation or the instance load.</span>**

*Compile time settings, which require instance reboot and can break instance loading:*
- all settings inside these keys:
  - `:hackney_pools`
  - `:chat`
- partially settings inside these keys:
  - `:seconds_valid` in `Pleroma.Captcha`
  - `:proxy_remote` in `Pleroma.Upload`
  - `:upload_limit` in `:instance`

## How to dump all settings from database to file
All settings will be dumped to `config/{env}.expoerted_from_db.secret.exs` if pleroma is runned from source.
For releases: `/etc/pleroma/prod.exported_from_db.secret.exs` or `PLEROMA_CONFIG_PATH/prod.exported_from_db.secret.exs`.

*Adding `-d` flag will delete migrated settings from database `config` table.*

```sh tab="OTP"
 ./bin/pleroma_ctl config migrate_from_db [-d]
```

```sh tab="From Source"
mix pleroma.config migrate_from_db [-d]
```

## How to completely remove it

1. Truncate or delete all values from `config` table
```sql
TRUNCATE TABLE config;
```
2. Delete `config/{env}.for_reboot.exs` and `config/{env}.exported_from_db.secret.exs`.

For `prod` env:
```bash
cd /opt/pleroma
cp config/prod.exported_from_db.secret.exs config/exported_from_db.back
rm -rf config/prod.for_reboot.exs
rm -rf config/prod.exported_from_db.secret.exs
```
*If you don't want to backup settings, you can skip step with `cp` command.*

3. Set configurable_from_database to `false`.
```elixir
config :pleroma, configurable_from_database: false
```
4. Restart pleroma instance
```bash
sudo service pleroma restart
```
