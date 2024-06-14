# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# set version label
ARG VERSION
ARG LIDARR_RELEASE
ARG LIDARR_BRANCH="nightly"

LABEL build_version=$VERSION
LABEL maintainer="nobody"

# environment settings
ENV XDG_CONFIG_HOME="/config/xdg"
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true

COPY build/_artifacts/linux-musl-x64/net6.0/Lidarr/ /app/lidarr/bin

RUN set -eux && \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    chromaprint \
    flac \
    icu-libs \
    sqlite-libs \
    xmlstarlet && \
  echo "**** install lidarr ****" && \
  mkdir -p /app/lidarr/bin && \
  echo -e "UpdateMethod=docker\nBranch=${LIDARR_BRANCH}\nPackageVersion=${VERSION}" > /app/lidarr/package_info && \
  printf "Custom version: ${VERSION}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/lidarr/bin/Lidarr.Update \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8686

VOLUME /config
