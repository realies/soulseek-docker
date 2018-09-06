from ubuntu:bionic
copy ui.patch /tmp
run apt-get update && \
 apt-get upgrade -y && \
 apt-get install -y binutils curl locales net-tools novnc openbox patch supervisor x11vnc xvfb && \
 locale-gen en_US.UTF-8 && \
 curl -fL# https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz -o /tmp/novnc.tar.gz && \
 tar -xvzf /tmp/novnc.tar.gz -C /tmp && \
 rm -rf /usr/share/novnc/* && \
 bash -c 'cp -r /tmp/noVNC*/{app,core,karma.conf.js,package.json,po,tests,utils,vendor,vnc.html,vnc_lite.html} /usr/share/novnc' && \
 curl -fL# https://use.fontawesome.com/releases/v5.0.10/svgs/solid/cloud-download-alt.svg -o /usr/share/novnc/app/images/downloads.svg && \
 curl -fL# https://use.fontawesome.com/releases/v5.0.10/svgs/solid/comments.svg -o /usr/share/novnc/app/images/logs.svg && \
 bash -c 'sed -i "s/<path/<path style=\"fill:white\"/" /usr/share/novnc/app/images/{downloads,logs}.svg' && \
 patch /usr/share/novnc/vnc.html < /tmp/ui.patch && \
 sed -i 's/10px 0 5px/8px 0 6px/' /usr/share/novnc/app/styles/base.css && \
 ln -s /squashfs-root/soulseek.png /usr/share/novnc/app/images/soulseek.png && \
 ln -s /root/Soulseek\ Chat\ Logs /usr/share/novnc/logs && \
 ln -s /root/Soulseek\ Downloads /usr/share/novnc/downloads && \
 curl -fL# https://dropbox.com/s/0vi87eef3ooh7iy/SoulseekQt-2018-1-30-64bit.tgz -o /tmp/soulseek.tgz && \
 tar -xvzf /tmp/soulseek.tgz -C /tmp && \
 /tmp/SoulseekQt-2018-1-30-64bit.AppImage --appimage-extract && \
 strip /squashfs-root/SoulseekQt && \
 apt-get purge -y binutils curl patch && \
 apt-get autoremove -y && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
env LANG en_US.UTF-8
env LANGUAGE en_US:en
env LC_ALL en_US.UTF-8
add etc /etc
add usr /usr
entrypoint ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
