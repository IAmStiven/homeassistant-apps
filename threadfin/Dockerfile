FROM golang:1.23-bullseye AS builder

WORKDIR /src

RUN git clone --depth=1 https://github.com/Threadfin/Threadfin.git .

RUN CGO_ENABLED=0 go build -mod=mod -ldflags="-s -w" -trimpath -o /out/threadfin threadfin.go

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl ffmpeg vlc tzdata jq \
    && sed -i 's/geteuid/getppid/' /usr/bin/vlc \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/threadfin /usr/local/bin/threadfin
COPY run.sh /usr/local/bin/homeassistant-run.sh

RUN chmod a+x /usr/local/bin/threadfin /usr/local/bin/homeassistant-run.sh

ENTRYPOINT ["/usr/local/bin/homeassistant-run.sh"]
