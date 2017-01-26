FROM debian:8.7
MAINTAINER Kevin Smith <kevin@kevinsmith.io>

# Install necessary libs
RUN apt-get update && apt-get install -y --no-install-recommends \
    sshfs \
    rsync \

  # Cleanup
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /mnt/remote

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
