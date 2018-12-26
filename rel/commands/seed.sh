#!/bin/sh

release_ctl eval --mfa "Pleroma.ReleaseTasks.Migrator.seed/1" --argv -- "$@"
