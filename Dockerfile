FROM python:3.11.3-alpine3.18
ADD .env .
RUN apk add --no-cache sqlite

WORKDIR /tmp/install

# Install dependencies and create a pre-compiled zipapp
RUN --mount=type=bind,target=.,rw \
    export PYTHONDONTWRITEBYTECODE=1 && \
    python -m pip install --no-cache-dir .[speed] && \
    python -m pip cache purge && \
    find -type f ! -iname *.py -delete && \
    python -m compileall discord_autodelete && \
    python -m zipfile -c ./discord_autodelete.zip discord_autodelete && \
    mkdir /app && cp ./discord_autodelete.zip /app/discord_autodelete.zip
WORKDIR /app

ENV PYTHONPATH="/app/discord_autodelete.zip${PYTHONPATH:+:$PYTHONPATH}"

ARG NO_BYTECODE=""
ENV PYTHONDONTWRITEBYTECODE="{$NO_BYTECODE:+1}"

ENTRYPOINT ["python", "-m", "discord_autodelete"]
