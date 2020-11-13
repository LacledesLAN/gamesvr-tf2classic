# escape=`
FROM lacledeslan/steamcmd:linux as tf2classic-builder

ARG contentServer=content.lacledeslan.net

# Download TF2 Classic server files
RUN echo "Downloading TF2 Classic from LL public ftp server" &&`
        mkdir --parents /tmp/ &&`
        curl -sSL "http://${contentServer}/fastDownloads/_installers/tf2classic-2.0.1.7z" -o /tmp/TF2Classic.7z &&`
    echo "Validating download against known hash" &&`
        echo "7e57eec3ce04402fe8a49056a55dd7e3392141bfbbfd5d636d007480a4636ace  /tmp/TF2Classic.7z" | sha256sum -c - &&`
    echo "Extracting TF2 Classic files" &&`
        7z x -o/output/ /tmp/TF2Classic.7z &&`
        rm -f /tmp/*.7z

# Download Source SDK Base 2013 Dedicated Server
RUN /app/steamcmd.sh +login anonymous +force_install_dir /output/srcds2013 +app_update 244310 validate +quit;

# TODO: Wire up and use the community updater

#=======================================================================
FROM debian:buster-slim

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

HEALTHCHECK NONE

RUN dpkg --add-architecture i386 &&`
    apt-get update && apt-get install -y `
        ca-certificates lib32gcc1 libtinfo5:i386 libcurl4-gnutls-dev:i386 libstdc++6 libstdc++6:i386 libtcmalloc-minimal4:i386 locales locales-all tmux zlib1g:i386 &&`
    apt-get clean &&`
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment &&`
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

LABEL com.lacledeslan.build-node=$BUILDNODE `
      org.label-schema.schema-version="1.0" `
      org.label-schema.url="https://github.com/LacledesLAN/README.1ST" `
      org.label-schema.vcs-ref=$SOURCE_COMMIT `
      org.label-schema.vendor="Laclede's LAN" `
      org.label-schema.description="TF2 Classic Dedicated Server" `
      org.label-schema.vcs-url="https://github.com/LacledesLAN/gamesvr-tf2classic"

# Set up Enviornment
RUN useradd --home /app --gid root --system TF2Classic &&`
    mkdir -p /app/tf2classic/logs &&`
    mkdir -p /app/ll-tests &&`
    chown TF2Classic:root -R /app;

COPY --chown=TF2Classic:root --from=tf2classic-builder /output/srcds2013 /app

COPY --chown=TF2Classic:root --from=tf2classic-builder /output/tf2classic /app/tf2classic

# Fix bad so names
RUN ln -s /app/bin/vphysics_srv.so /app/bin/vphysics.so &&`
    ln -s /app/bin/studiorender_srv.so /app/bin/studiorender.so &&`
    ln -s /app/bin/soundemittersystem_srv.so /app/bin/soundemittersystem.so &&`
    ln -s /app/bin/shaderapiempty_srv.so /app/bin/shaderapiempty.so &&`
    ln -s /app/bin/scenefilecache_srv.so /app/bin/scenefilecache.so &&`
    ln -s /app/bin/replay_srv.so /app/bin/replay.so &&`
    ln -s /app/bin/materialsystem_srv.so /app/bin/materialsystem.so;

#COPY --chown=TF2Classic:root ./ll-tests /app/ll-tests

#RUN chmod +x /app/ll-tests/*.sh

USER TF2Classic

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
