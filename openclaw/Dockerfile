FROM oven/bun:1.2.5

ENV PATH="/root/.bun/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq ca-certificates openssh-client git curl bash \
    && rm -rf /var/lib/apt/lists/* \
    && bun install -g openclaw@2026.3.7

COPY run.sh /usr/local/bin/homeassistant-run.sh
COPY openclaw.template.json5 /etc/openclaw/openclaw.template.json5

RUN chmod a+x /usr/local/bin/homeassistant-run.sh

ENTRYPOINT ["/usr/local/bin/homeassistant-run.sh"]
