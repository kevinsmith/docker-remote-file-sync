FROM debian:jessie
MAINTAINER Kevin Smith <kevin@kevinsmith.io>

# Install sshfs
RUN apt-get update && apt-get install -y --no-install-recommends \
    sshfs \
    rsync \

  # Cleanup
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /mnt/remote

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
