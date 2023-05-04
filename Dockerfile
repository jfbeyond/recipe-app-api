FROM python:3.9-alpine3.13
LABEL maintainer="github.com/jfbeyond"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# This runs all lines in one single layer to keep the application lightweight
# I could just add RUN to each one of them
# The first line creates a virtual environment in the container. People have conflictint
# opinions about it. But this will guarantee to have the proper dependencies for my app

# The ARG was added to handle the flake usage (see also docker-compose) which will be utilized
# only in development
# Added lines to include packages for postgresql connections and also remove them once
# they're installed and running to keep docker lightweight
# first line is for psycopg which stays while running the other one is temporary (.tmp-build-dev)
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

ENV PATH="/py/bin:$PATH"

USER django-user