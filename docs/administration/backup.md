# Backup/Restore/Move your instance

## Backup

1. Stop the Pleroma service.
2. Go to the working directory of Pleroma (default is `/opt/pleroma`)
3. Run `sudo -Hu postgres pg_dump -d <pleroma_db> --format=custom -f </path/to/backup_location/pleroma.pgdump>` (make sure the postgres user has write access to the destination file)
4. Copy `pleroma.pgdump`, `config/prod.secret.exs` and the `uploads` folder to your backup destination. If you have other modifications, copy those changes too.
5. Restart the Pleroma service.

## Restore/Move

1. Optionally reinstall Pleroma (either on the same server or on another server if you want to move servers). Try to use the same database name.
2. Stop the Pleroma service.
3. Go to the working directory of Pleroma (default is `/opt/pleroma`)
4. Copy the above mentioned files back to their original position.
5. Drop the existing database and recreate an empty one `sudo -Hu postgres psql -c 'DROP DATABASE <pleroma_db>;';` `sudo -Hu postgres psql -c 'CREATE DATABASE <pleroma_db>;';`
6. Run `sudo -Hu postgres pg_restore -d <pleroma_db> -v -1 </path/to/backup_location/pleroma.pgdump>`
7. If you installed a newer Pleroma version, you should run `mix ecto.migrate`[^1]. This task performs database migrations, if there were any.
8. Restart the Pleroma service.

[^1]: Prefix with `MIX_ENV=prod` to run it using the production config file.
