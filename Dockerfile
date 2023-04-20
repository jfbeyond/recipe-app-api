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
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user