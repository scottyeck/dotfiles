#!/bin/bash

set -e

if [ -z "$EXEC_NAME" ]; then
  echo 'common.sh: ERROR Cannot initialize common lib for exec without var \"$EXEC_NAME\"'
  return 1
fi

logGeneric () {
  echo "$EXEC_NAME: $@"
}

logError () {
  logGeneric "ERROR" "$@"
}

