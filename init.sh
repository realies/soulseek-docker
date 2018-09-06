#/bin/sh
resolution=${resolution:-1280x720}x16
[ ! -f /etc/supervisord.conf ] && echo "[supervisord]
nodaemon=true

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
command=/usr/share/novnc/utils/launch.sh
autorestart=true
priority=400

[program:soulseek]
environment=HOME="/root",DISPLAY=":1",USER="root"
command=/squashfs-root/SoulseekQt
autorestart=true
priority=500" > /etc/supervisord.conf
/usr/bin/supervisord -c /etc/supervisord.conf
