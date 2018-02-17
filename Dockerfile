from ubuntu:latest
run apt-get update && \
 apt-get upgrade -y && \
 apt-get install -y supervisor xvfb x11vnc openbox curl && \
 sed -i 's/<number>4<\/number>/<number>1<\/number>/g' /etc/xdg/openbox/rc.xml && \
 curl -fL# https://www.dropbox.com/s/7qh902qv2sxyp6p/SoulseekQt-2016-1-17-64bit.tgz?dl=0 -o /tmp/soulseek.tgz && \
 tar -xvzf /tmp/soulseek.tgz -C /tmp && \
 mv /tmp/SoulseekQt* /usr/bin/soulseek && \
 rm /tmp/soulseek.tgz && \
 apt-get purge -y curl && \
 apt-get autoremove -y && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
add etc /etc
expose 5900
entrypoint ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
