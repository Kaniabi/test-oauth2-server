#!/bin/bash

set -e

## REF: https://stackoverflow.com/questions/6174220/parse-url-in-shell-script
PGFIELDS=($(echo $DATABASE_URL | awk '{split($0, arr, /[\/\@:]/); for (x in arr) { print arr[x] }}'))
PGUSER=${PGFIELDS[1]}
PGPASSWORD=${PGFIELDS[2]}
PGHOST=${PGFIELDS[3]}
PGPORT=${PGFIELDS[4]}
PGDATABASE=${PGFIELDS[5]}

wait_for_db () {
  # Wait until postgresql is up and running.
  # Looping pg_isready, because the database can receive a fast-restart
  # command during the first init, and pg_isready will then immediately quit
  # with "rejecting connections" error.
  for _ in $(seq 5); do
    if ! pg_isready -h $PGHOST -t 360
    then
      sleep 3  # Wait 3s between retries
    else
      break
    fi
  done
}

cd /app
if [ $# -eq 0 ]; then
    # No arguments, simply run the app
    wait_for_db
    createdb $PGNAME || true
    python /app/manage.py migrate
    python /app/manage.py initialize
    nginx -g "daemon off;" &                            # Start http web-server
    # exec uvicorn oauth2_server.asgi:application

    # Start uvicorn
    exec gunicorn -w 4 -k uvicorn.workers.UvicornWorker oauth2_server.asgi:application

else
    # Pass all arguments to manage.py
    python /app/manage.py "${@}"
fi
