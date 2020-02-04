#!/bin/bash

set -e

_ORIGIN_BRANCH=${TRAVIS_BRANCH:-master}

export PGFIELDS=($(echo $DATABASE_URL | awk '{split($0, arr, /[\/\@:]/); for (x in arr) { print arr[x] }}'))
export PGUSER=${PGFIELDS[1]}
export PGPASSWORD=${PGFIELDS[2]}
export PGHOST=${PGFIELDS[3]}
export PGPORT=${PGFIELDS[4]}
export PGDATABASE=${PGFIELDS[5]}

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

runserver () {
  python /app/manage.py migrate
  python /app/manage.py collectstatic --no-input
  python /app/manage.py initialize
  exec python /app/manage.py runserver 0.0.0.0:8880
}


cd /app

if [[ "$1" == "" ]]; then
  _CMD="run-clean"
else
  _CMD=$1
  shift
fi

case $_CMD in

  "exec")
    wait_for_db
    exec "${@}"
    ;;

  "manage")
    wait_for_db
    python manage.py "${@}"
    ;;

  "python")
    exec python "${@}"
    ;;

  "run-clean")
    wait_for_db
    dropdb $PGDATABASE || true
    createdb $PGDATABASE || true
    runserver
    ;;

  "run-dev")
    wait_for_db
    runserver
    ;;

  "shell")
    exec /bin/bash
    ;;

  "update-requirements")
    pip install -U pip-tools
    exec pip-compile --no-header --output-file=requirements.txt requirements.in
    ;;

  "--help")
    print_help
    ;;

  *)
    echo "ERROR: Unknown command: $_CMD."
    print_help
    exit 1
    ;;

esac
