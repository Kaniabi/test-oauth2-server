FROM python:3.8-alpine

# Runtime dependencies
RUN apk add --update --no-cache \
    nginx \
    zlib \
    postgresql-client \
    bash

ADD requires.txt /app/requires.txt
RUN apk add --update --no-cache \
    gcc linux-headers musl-dev make zlib-dev postgresql-dev \
    && pip install -r /app/requires.txt

ADD . /app
RUN chmod +x /app/docker/entrypoint.sh

ADD docker/etc/nginx.conf /etc/nginx/nginx.conf
RUN python /app/manage.py collectstatic --noinput

ENTRYPOINT ["/app/docker/entrypoint.sh"]
