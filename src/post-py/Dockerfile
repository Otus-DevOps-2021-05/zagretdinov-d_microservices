FROM python:3.6.14-alpine

WORKDIR /app

ADD requirements.txt /app

RUN apk --no-cache --update add build-base && \
    pip install -r /app/requirements.txt && \
    apk del build-base

ADD . /app

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts
EXPOSE  5000
ENTRYPOINT ["python3", "post_app.py"]

