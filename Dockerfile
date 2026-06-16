# syntax=docker/dockerfile:1@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89

FROM mirror.gcr.io/alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

ARG TARGETARCH
ARG VERSION
ARG FRAMEWORK

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_EnableDiagnostics=0 \
  LIDARR__UPDATE__BRANCH=nightly

USER root
WORKDIR /app

COPY --chown=0:0 --chmod=755 \
  packages/linux-musl-${TARGETARCH/amd64/x64}/${FRAMEWORK}/Lidarr/ /app/lidarr/bin

RUN set -eux && \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    bash \
    ca-certificates \
    catatonit \
    chromaprint \
    curl \
    flac \
    icu-libs \
    tzdata && \
  echo "**** install lidarr ****" && \
  mkdir -p /app/lidarr/bin && \
  echo -e "UpdateMethod=docker\nBranch=${LIDARR__UPDATE__BRANCH}\nPackageVersion=${VERSION}" > /app/lidarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/lidarr/bin/Lidarr.Update \
    /tmp/*

COPY root/ /

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

EXPOSE 8686

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
