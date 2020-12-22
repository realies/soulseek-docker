FROM ubuntu:bionic
COPY ui.patch /tmp
RUN apt-get update && \
 apt-get install -y binutils ca-certificates curl dbus libssl1.0-dev locales openbox patch supervisor x11vnc xvfb python3 --no-install-recommends && \
 dbus-uuidgen > /etc/machine-id && \
 locale-gen en_US.UTF-8 && \
 mkdir /usr/share/novnc && \
 curl -fL# https://github.com/novnc/noVNC/archive/master.tar.gz -o /tmp/novnc.tar.gz && \
 tar -xf /tmp/novnc.tar.gz --strip-components=1 -C /usr/share/novnc && \
 mkdir /usr/share/novnc/utils/websockify && \
 curl -fL# https://github.com/novnc/websockify/archive/master.tar.gz -o /tmp/websockify.tar.gz && \
 tar -xf /tmp/websockify.tar.gz --strip-components=1 -C /usr/share/novnc/utils/websockify && \
 curl -fL# https://use.fontawesome.com/releases/v5.12.0/svgs/solid/cloud-download-alt.svg -o /usr/share/novnc/app/images/downloads.svg && \
 curl -fL# https://use.fontawesome.com/releases/v5.12.0/svgs/solid/comments.svg -o /usr/share/novnc/app/images/logs.svg && \
 bash -c 'sed -i "s/<path/<path style=\"fill:white\"/" /usr/share/novnc/app/images/{downloads,logs}.svg' && \
 patch /usr/share/novnc/vnc.html < /tmp/ui.patch && \
 sed -i 's/10px 0 5px/8px 0 6px/' /usr/share/novnc/app/styles/base.css && \
 ln -s /app/soulseek.png /usr/share/novnc/app/images/soulseek.png && \
 ln -s /data/Soulseek\ Chat\ Logs /usr/share/novnc/logs && \
 ln -s /data/Soulseek\ Downloads /usr/share/novnc/downloads && \
 curl -fL# https://www.slsknet.org/SoulseekQt/Linux/SoulseekQt-2018-1-30-64bit-appimage.tgz -o /tmp/soulseek.tgz && \
 tar -xvzf /tmp/soulseek.tgz -C /tmp && \
 /tmp/SoulseekQt-2018-1-30-64bit.AppImage --appimage-extract && \
 mv /squashfs-root /app && \
 strip /app/SoulseekQt && \
 useradd -u 1000 -U -d /data -s /bin/false soulseek && \
 usermod -G users soulseek && \
 mkdir /data && \
 apt-get purge -y binutils curl dbus patch && \
 apt-get autoremove -y && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    XDG_RUNTIME_DIR=/data
COPY etc /etc
COPY usr /usr
COPY init.sh /init.sh
ENTRYPOINT ["/init.sh"]
