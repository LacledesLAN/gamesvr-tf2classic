# escape=`
FROM lacledeslan/steamcmd:linux as tf2classic-builder

ARG contentServer=content.lacledeslan.net

# Download TF2 Classic server files
RUN echo "Downloading" &&`
        mkdir --parents /tmp/ &&`
        curl -sSL "http://${contentServer}/fastDownloads/_installers/tf2classic-2.0.3_linux_full.zip" -o /tmp/tf2classic.zip &&`
    echo "Validating download against known hash" &&`
        echo "773ec9e51144208a1800771395d88304ef1acfd14460c305269f477bd5c80cd7  /tmp/tf2classic.zip" | sha256sum -c - &&`
    echo "Extracting" &&`
        7z x -o/output/ /tmp/tf2classic.zip &&`
        rm -f /tmp/tf2classic.zip;

# Download Source SDK Base 2013 Dedicated Server
RUN /app/steamcmd.sh +login anonymous +force_install_dir /output/srcds2013 +app_update 244310 validate +quit;

# TODO: ?Wire up the community updater?

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

# `RUN true` lines are work around for https://github.com/moby/moby/issues/36573
COPY --chown=TF2Classic:root --from=tf2classic-builder /output/srcds2013 /app
RUN true
COPY --chown=TF2Classic:root --from=tf2classic-builder /output/tf2classic /app/tf2classic
RUN true
COPY --chown=TF2Classic:root ./dist/linux/ll-tests /app/ll-tests

# Fix bad so names
RUN chmod +x /app/ll-tests/*.sh &&`
    ln -s /app/bin/vphysics_srv.so /app/bin/vphysics.so &&`
    ln -s /app/bin/studiorender_srv.so /app/bin/studiorender.so &&`
    ln -s /app/bin/soundemittersystem_srv.so /app/bin/soundemittersystem.so &&`
    ln -s /app/bin/shaderapiempty_srv.so /app/bin/shaderapiempty.so &&`
    ln -s /app/bin/scenefilecache_srv.so /app/bin/scenefilecache.so &&`
    ln -s /app/bin/replay_srv.so /app/bin/replay.so &&`
    ln -s /app/bin/materialsystem_srv.so /app/bin/materialsystem.so;

USER TF2Classic

RUN echo $'\n\nLinking steamclient.so to prevent srcds_run errors' &&`
        mkdir --parents /app/.steam/sdk32 &&`
        ln -s /app/bin/steamclient.so /app/.steam/sdk32/steamclient.so;

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
