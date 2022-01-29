#!/bin/sh
set -e
umask 0000
[ -f /tmp/.X1-lock ] && rm /tmp/.X1-lock
pgid=${pgid:-0}
puid=${puid:-0}
[ "$pgid" != 0 ] && [ "$puid" != 0 ] && \
 groupmod -o -g "$pgid" soulseek && \
 usermod -o -u "$puid" soulseek && \
 chown -R soulseek:soulseek /app && \
 chown soulseek:soulseek /data/.* && \
 chown soulseek:soulseek /data/*
[ "$resize" = "auto" ] && sed -r -i '/src/s/"[^"]+"/"vnc.html?autoconnect=true"/' /usr/share/novnc/index.html
[ "$resize" = "scale" ] && sed -r -i '/src/s/"[^"]+"/"vnc.html?autoconnect=true\&resize=scale"/' /usr/share/novnc/index.html
[ "$resize" = "remote" ] && sed -r -i '/src/s/"[^"]+"/"vnc.html?autoconnect=true\&resize=remote"/' /usr/share/novnc/index.html
resolution=${resolution:-1280x720}x16
[ ! -f /etc/supervisord.conf ] && username=$(getent passwd "$puid" | cut -d: -f1) && echo "[supervisord]
nodaemon=true
logfile = /tmp/supervisord.log
pidfile = /tmp/supervisord.pid
directory = /tmp
childlogdir = /tmp

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 $resolution
autorestart=true
priority=100

[program:x11vnc]
command=/usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :1 -nopw -wait 5 -shared -permitfiletransfer -tightfilexfer -rfbport 5900
autorestart=true
priority=200

[program:openbox]
environment=HOME="/root",DISPLAY=":1",USER="root"
command=/usr/bin/openbox
autorestart=true
priority=300

[program:novnc]
command=/usr/share/novnc/utils/novnc_proxy
autorestart=true
priority=400

[program:soulseek]
user=$username
environment=HOME="/data",DISPLAY=":1",USER="$username"
command=/app/SoulseekQt
autorestart=true
priority=500" > /etc/supervisord.conf
/usr/bin/supervisord -c /etc/supervisord.conf
