#!/bin/sh

set -e

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
