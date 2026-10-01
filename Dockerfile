ARG ALPINE=3.24.2
ARG T2S=v2.6.0

FROM alpine:${ALPINE}
LABEL org.opencontainers.image.authors="Axl <https://github.com/ADKix>"
RUN apk add -U --no-cache 7zip util-linux-misc iproute2-minimal
ARG T2S
ARG TARGETPLATFORM
WORKDIR "/opt"
RUN if   [ "${TARGETPLATFORM}" = "linux/arm64" ] || [ "${TARGETPLATFORM}" = "linux/arm64/v8" ]; then arch=arm64; \
    elif [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then arch=armv7; \
    elif [ "${TARGETPLATFORM}" = "linux/386" ]; then arch=386; \
    elif [ "${TARGETPLATFORM}" = "linux/amd64" ]; then arch=amd64; fi; \
    wget -qnc "https://github.com/xjasonlyu/tun2socks/releases/download/${T2S}/tun2socks-linux-${arch}.zip" -O- | \
      unzip -p - "tun2socks-linux-${arch}" | \
        7z -si a "tun2socks.7z"
COPY "entrypoint.sh" "command.sh" /
ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["sh", "/command.sh"]
ENV PORT=1080
