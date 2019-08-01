# flog

> An extremely dumb and opinionated tool used to archive dumped logs from `awslogs`

## TLDR;

```sh
$ flog peel-banana --start="45mins"
# > Outputs logs to ~/tmp/logs/peel-banana/2019-01-19T14:07:23Z
```

## Motivation

Typically I'd use `awslogs` to grab lambda logs like this. Note use of [`now`](./README.now.md).

```sh
$ LOGS_DIR=~/tmp/logs
$ LAMBDA_NAME=peel-banana
$ mkdir -p $LOGS_DIR
$ awslogs get /aws/logs/$LAMBDA_NAME --start="45mins" > $LOGS_DIR/$LAMBDA_NAME/$(now).txt
```

Did this too many times. Too many repeated steps. Blech.
