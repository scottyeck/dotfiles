# now

> A shortcut to print the current date-time in ISO-8601.

## TLDR;

```sh
$ now
# > 2019-01-19T14:07:23Z
```

## Motivation

Makes it easier to work with logs. Basically, if I'm grabbing logs, my workflow looks like this.

```
$ LAMBDA=some-really-extremely-long-lambda-name
$ mkdir -p ~/tmp/logs/$LAMBDA
$ awslogs get $LAMBDA --start="2hrs" > ~/tmp/logs/$LAMBDA/$(now).txt
```

If I'm grabbing multiple sets it makes life easier to just name the file with a timestamp based on when it was created. Rather than having to remember the particular format I want to pass to `date`, I've basically just aliased it here.