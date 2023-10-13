#!/bin/bash

set -e

if [ -z "$EXEC_NAME" ]; then
  echo 'common.sh: ERROR Cannot initialize common lib for exec without var \"$EXEC_NAME\"'
  return 1
fi

log_generic () {
  echo "$EXEC_NAME: $@"
}

log_error () {
  log_generic "ERROR" "$@" >&2
}
