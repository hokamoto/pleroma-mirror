# Creating trusted OAuth App

{! backend/administration/CLI_tasks/general_cli_task_info.include !}

## Create trusted OAuth App.

```sh tab="OTP"
 ./bin/pleroma_ctl app create -n APP_NAME -r REDIRECT_URI
```

```sh tab="From Source"
mix pleroma.app create -n APP_NAME -r REDIRECT_URI
```