FROM alpine:3.13

RUN mkdir /work \
 && cd /work \
 # Get Restic
 && wget -O restic.bz2 https://github.com/restic/restic/releases/download/v0.11.0/restic_0.11.0_linux_amd64.bz2 \
 && bzip2 -d restic.bz2 \
 && chmod a+x restic \
 && mv restic /usr/local/bin/restic \
 # Get rclone
 && wget https://downloads.rclone.org/rclone-current-linux-amd64.zip \
 && unzip rclone-current-linux-amd64.zip \
 && mv rclone-*-linux-amd64/rclone /usr/local/bin/rclone \
 && cd / \
 && rm -rf /work

RUN apk add --update --no-cache \
        ca-certificates \
        fuse \
        openssh \
        mariadb-client \
        postgresql-client \
        mongodb-tools \
 && update-ca-certificates \
 && rm -rf /var/cache/apk/*

COPY backup.sh entrypoint.sh /usr/local/sbin/

VOLUME /repository
VOLUME /data

ENV SCHEDULE="0 2 * * *"

ENV BACKUP_BEFORE_COMMAND=""

ENV RESTIC_REPOSITORY=/repository
ENV RESTIC_PASSWORD=""
ENV RESTIC_TAG=""
ENV RESTIC_JOB_ARGS=""
ENV RESTIC_FORGET_ARGS=""

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["/usr/sbin/crond", "-f", "-L", "/dev/stdout"]
