# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.22

ARG VERSION

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_EnableDiagnostics=0 \
  LIDARR__UPDATE__BRANCH=nightly
  
USER root
WORKDIR /app

COPY --chown=0:0 --chmod=755 \
  build/_artifacts/linux-musl-x64/net6.0/Lidarr/ /app/lidarr/bin

RUN set -eux && \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    bash \
    ca-certificates \
    catatonit \
    chromaprint \
    flac \
    icu-libs \
    sqlite-libs \
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
