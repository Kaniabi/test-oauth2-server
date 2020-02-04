FROM python:3.8-alpine

# Runtime dependencies
RUN apk add --update --no-cache \
    nginx \
    zlib \
    postgresql-client \
    bash

ADD requirements.txt /app/requirements.txt
RUN apk add --update --no-cache --virtual build-deps \
    gcc linux-headers musl-dev make zlib-dev postgresql-dev  \
    && pip install --no-cache -r /app/requirements.txt  \
    && apk del build-deps

ADD . /app
RUN chmod +x /app/docker/entrypoint.sh  \
    && python /app/manage.py collectstatic --noinput

ENTRYPOINT ["/app/docker/entrypoint.sh"]
