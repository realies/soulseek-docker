#!/bin/sh
set -e
[ -f /tmp/.X1-lock ] && rm /tmp/.X1-lock
pgid=${pgid:-0}
puid=${puid:-0}
umask ${umask:-0000}
[ "$pgid" != 0 ] && [ "$puid" != 0 ] && \
 groupmod -o -g "$pgid" soulseek && \
 usermod  -o -u "$puid" soulseek 1> /dev/null && \
 chown -R soulseek:soulseek /app && \
 chown soulseek:soulseek /data/.* && \
 chown soulseek:soulseek /data/*

[ ! -z "${vncpwd}" ] && echo "$vncpwd" | vncpasswd -f > /tmp/passwd
[ -z "${vncpwd}" ] && rm -f /tmp/passwd && noauth="-SecurityTypes None"

touch /tmp/.Xauthority
chown soulseek:soulseek /tmp/.Xauthority

[ -n "$timeZone" ] && [ -f "/usr/share/zoneinfo/$timeZone" ] && ln -sf "/usr/share/zoneinfo/$timeZone" /etc/localtime

[ ! -f /etc/supervisord.conf ] && username=$(getent passwd "$puid" | cut -d: -f1) && echo "[supervisord]
user=$username
nodaemon=true
logfile = /tmp/supervisord.log
pidfile = /tmp/supervisord.pid
directory = /tmp
childlogdir = /tmp

[program:tigervnc]
user=$username
environment=HOME="/tmp",DISPLAY=":1",USER="$username"
command=/usr/bin/Xtigervnc -desktop soulseek -auth /tmp/.Xauthority -rfbport 5900 -nopn -rfbauth /tmp/passwd -quiet -AlwaysShared $noauth :1
autorestart=true
priority=100

[program:openbox]
user=$username
environment=HOME="/tmp",DISPLAY=":1",USER="$username"
command=/usr/bin/openbox
autorestart=true
priority=200

[program:novnc]
user=$username
environment=HOME="/tmp",DISPLAY=":1",USER="$username"
command=/usr/share/novnc/utils/novnc_proxy
autorestart=true
priority=300

[program:soulseek]
user=$username
environment=HOME="/data",DISPLAY=":1",USER="$username"
command=/app/SoulseekQt
autorestart=true
priority=400" > /etc/supervisord.conf
/usr/bin/supervisord -c /etc/supervisord.conf
