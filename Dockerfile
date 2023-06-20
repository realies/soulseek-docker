FROM ubuntu:latest
COPY ui.patch /tmp
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y binutils ca-certificates curl dbus fonts-noto-cjk locales openbox patch supervisor tigervnc-standalone-server tigervnc-tools tzdata xterm vim unzip --no-install-recommends && \
    dbus-uuidgen > /etc/machine-id && \
    locale-gen en_US.UTF-8 && \
    mkdir /usr/share/novnc && \
    curl -fL# https://github.com/novnc/noVNC/archive/master.tar.gz -o /tmp/novnc.tar.gz && \
    tar -xf /tmp/novnc.tar.gz --strip-components=1 -C /usr/share/novnc && \
    mkdir /usr/share/novnc/utils/websockify && \
    curl -fL# https://github.com/novnc/websockify/archive/master.tar.gz -o /tmp/websockify.tar.gz && \
    tar -xf /tmp/websockify.tar.gz --strip-components=1 -C /usr/share/novnc/utils/websockify && \
    curl -fL# https://site-assets.fontawesome.com/releases/v6.0.0/svgs/solid/cloud-arrow-down.svg -o /usr/share/novnc/app/images/downloads.svg && \
    curl -fL# https://site-assets.fontawesome.com/releases/v6.0.0/svgs/solid/folder-music.svg -o /usr/share/novnc/app/images/shared.svg && \
    curl -fL# https://site-assets.fontawesome.com/releases/v6.0.0/svgs/solid/comments.svg -o /usr/share/novnc/app/images/logs.svg && \
    bash -c 'sed -i "s/<path/<path style=\"fill:white\"/" /usr/share/novnc/app/images/{downloads,logs,shared}.svg' && \
    patch /usr/share/novnc/vnc.html < /tmp/ui.patch && \
    sed -i 's/10px 0 5px/8px 0 6px/' /usr/share/novnc/app/styles/base.css && \
    mkdir /data /data/config /data/nicotine /share && \
    ln -s /data/nicotine/downloads /usr/share/novnc/downloads && \
    ln -s /share /usr/share/novnc/shared && \
    ln -s /data/nicotine/logs /usr/share/novnc/logs && \
    apt-get install -y adwaita-icon-theme dbus-user-session dconf-gsettings-backend dconf-service gir1.2-atk-1.0 gir1.2-freedesktop gir1.2-gdkpixbuf-2.0 gir1.2-glib-2.0 gir1.2-gtk-3.0 gir1.2-harfbuzz-0.0 gir1.2-pango-1.0 gtk-update-icon-cache hicolor-icon-theme humanity-icon-theme libargon2-1 libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0 libavahi-client3 libavahi-common-data libavahi-common3 libcolord2 libcryptsetup12 libcups2 libdconf1 libdevmapper1.02.1 libepoxy0 libgirepository-1.0-1 libgtk-3-0 libgtk-3-common libip4tc2 libjson-c5 libkmod2 liblcms2-2 libpam-systemd libwayland-client0 libwayland-cursor0 libwayland-egl1 libxcomposite1 libxdamage1 libxkbcommon0 python3-gdbm python3-gi systemd systemd-sysv ubuntu-mono --no-install-recommends && \
    curl -fL# https://github.com/nicotine-plus/nicotine-plus/releases/latest/download/debian-package.zip -o /tmp/nic.zip && \
    unzip /tmp/nic.zip -d /tmp && \
    dpkg -i /tmp/nicotine*.deb && \
    ln -s /usr/share/icons/hicolor/256x256/apps/org.nicotine_plus.Nicotine.png /usr/share/novnc/app/images/nicotine.png && \
    useradd -u 1000 -U -d /data -s /bin/false soulseek && \
    usermod -G users soulseek && \
    chown -R soulseek:soulseek /data && \
    apt-get purge -y binutils curl patch && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    XDG_RUNTIME_DIR=/data \
    XDG_CONFIG_HOME=/data/config \
    XDG_DATA_HOME=/data
COPY etc /etc
COPY usr /usr
COPY init.sh /init.sh
ENTRYPOINT ["/init.sh"]
