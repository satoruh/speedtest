FROM debian:stable-slim

RUN apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qy install curl jq && \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qy install speedtest

COPY ./entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
