# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e

FROM mirror.gcr.io/alpine:3.24.4@sha256:93b41ef40b1677fce8fcc64ff4af09daddfacf5040afde618bc46c1e2d1cc7d4

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
  apk add --no-cache --upgrade \
    bash \
    ca-certificates \
    catatonit \
    curl \
    flac \
    icu-libs \
    jq \
    krb5-libs \
    tzdata && \
  echo "**** install lidarr ****" && \
  mkdir -p /app/lidarr/bin && \
  echo -e "UpdateMethod=docker\nBranch=${LIDARR__UPDATE__BRANCH}\nPackageVersion=${VERSION}" > /app/lidarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/lidarr/bin/Lidarr.Update \
    /var/log/* \
    /tmp/*

COPY root/ /

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

EXPOSE 8686

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
