FROM python:3.8-alpine

RUN apk add --update --no-cache \
    gcc \
    linux-headers \
    musl-dev \
    make \
    nginx \
    postgresql-dev \
    postgresql-client \
    zlib \
    zlib-dev

ADD requires.txt /app/requires.txt
RUN pip install -r /app/requires.txt

ADD . /app
RUN chmod +x /app/docker/entrypoint.sh

ADD docker/etc/nginx.conf /etc/nginx/nginx.conf
RUN python /app/manage.py collectstatic --noinput

ENTRYPOINT ["/app/docker/entrypoint.sh"]
