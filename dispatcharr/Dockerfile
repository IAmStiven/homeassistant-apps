FROM ghcr.io/dispatcharr/dispatcharr:latest

COPY run.sh /usr/local/bin/homeassistant-run.sh

RUN chmod a+x /usr/local/bin/homeassistant-run.sh

ENTRYPOINT ["/usr/local/bin/homeassistant-run.sh"]
