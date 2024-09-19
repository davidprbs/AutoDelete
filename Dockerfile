FROM python:3.9.20-alpine3.20
ADD .env .
RUN apk update && apk upgrade
RUN apk add --no-cache sqlite
RUN apk add --no-cache --virtual .pynacl_deps build-base python3-dev libffi-dev

WORKDIR /tmp/install

# Install dependencies and create a pre-compiled zipapp
RUN --mount=type=bind,target=.,rw \
    export PYTHONDONTWRITEBYTECODE=1 && \
    python3 -m pip install --no-cache-dir .[speed] && \
    python3 -m pip cache purge && \
    find -type f ! -iname *.py -delete && \
    python3 -m compileall discord_autodelete && \
    python3 -m zipfile -c ./discord_autodelete.zip discord_autodelete && \
    mkdir /app && cp ./discord_autodelete.zip /app/discord_autodelete.zip
WORKDIR /app

ENV PYTHONPATH="/app/discord_autodelete.zip${PYTHONPATH:+:$PYTHONPATH}"

ARG NO_BYTECODE=""
ENV PYTHONDONTWRITEBYTECODE="{$NO_BYTECODE:+1}"

ENTRYPOINT ["python3", "-m", "discord_autodelete"]
