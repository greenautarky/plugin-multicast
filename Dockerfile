ARG BUILD_FROM
FROM ${BUILD_FROM}

SHELL ["/bin/ash", "-o", "pipefail", "-c"]
ARG BUILD_ARCH

# The armv7 base image is no longer rebuilt upstream, so its Alpine packages
# only age. Pull the current 3.22 package updates on top of it.
# hadolint ignore=DL3017
RUN apk upgrade --no-cache

# tempio from its current release (the base image carries an older build).
# Checksum-pinned; only the armv7 binary is pinned because only armv7 is built.
ARG TEMPIO_VERSION=2026.07.0
ARG TEMPIO_SHA256=1887c4721317ee166de703ddb30f906c9f98f01f08a6b2da295c10946a0c8110
RUN \
    curl -Lfso /usr/bin/tempio "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}" \
    && echo "${TEMPIO_SHA256}  /usr/bin/tempio" | sha256sum -c - \
    && chmod a+x /usr/bin/tempio

ARG MDNS_REPEATER_VERSION
RUN \
    apk add --no-cache --virtual .build-deps \
        build-base \
        git \
    \
    && git clone -b ${MDNS_REPEATER_VERSION} --depth 1 \
        https://github.com/pvizeli/mdns-repeater /usr/src/mdns \
    && cd /usr/src/mdns \
    && gcc -O3 -o /usr/bin/mdns-repeater \
        mdns-repeater.c -DVERSION="\"${MDNS_REPEATER_VERSION}\"" \
    \
    && apk del .build-deps \
    && rm -rf \
        /usr/src/mdns

COPY rootfs /
