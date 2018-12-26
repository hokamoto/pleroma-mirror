#!/bin/sh

release_ctl eval --mfa "Pleroma.ReleaseTasks.Migrator.migrate/1" --argv -- "$@"
