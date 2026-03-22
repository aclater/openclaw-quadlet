FROM ghcr.io/openclaw/openclaw:slim
USER root
RUN npm install -g sonos-cli
USER node
