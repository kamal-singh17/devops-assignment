#!/bin/bash

case "$1" in
  start)
    docker compose --profile core --profile app up -d
    ;;
  monitoring)
    docker compose --profile monitoring up -d
    ;;
  full)
    docker compose --profile core --profile app --profile monitoring up -d
    ;;
  stop)
    docker compose down
    ;;
  pause)
    docker compose pause
    ;;
  *)
    echo "Usage: start | monitoring | full | stop | pause"
    ;;
esac
