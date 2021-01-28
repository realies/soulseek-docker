![](https://i.snag.gy/8dpAbV.jpg)

![](https://img.shields.io/docker/automated/realies/soulseek?style=flat-square)
![](https://img.shields.io/docker/build/realies/soulseek?style=flat-square)
![](https://img.shields.io/docker/pulls/realies/soulseek?style=flat-square)
![](https://img.shields.io/microbadger/image-size/realies/soulseek?style=flat-square)

## Typical Usage

##### Using Docker Compose
```
docker-compose up -d
```

##### Using Docker CLI
```
docker run -d --name soulseek --restart=always \
-v "/persistent/appdata":"/data/.SoulseekQt" \
-v "/persistent/downloads":"/data/Soulseek Downloads" \
-v "/persistent/logs":"/data/Soulseek Chat Logs" \
-e pgid=1000 \
-e puid=1000 \
-e resize=scale \
-e resolution=1280x720 \
-e vncpwds="password1;password2"
-p 6080:6080 \
realies/soulseek
```

##### Configuration Parameters
```
pgid          optional, only works if puid is set, chown app folders to the specified group id
puid          optional, only works if pgid is set, chown app folders to the specified user id, run the app with the specified user id
resize        optional, set the novnc resize mode, defaults to scale, can be:
                  auto      honour browser's local storage
                  scale     scale the session to the browser window size
                  remote    scale the session to the remote session size
resolution    optional, set the xvfb resolution, defaults to 1280x720
vncpwds       optional, protect x11vnc with one ore more passwords serparated by semicolons. If not set, no password will be required by client.
timeZone      optional, set the local timeZone, examples:
                  Europe/Paris
                  Asia/Macao
                  America/Vancouver
                  ... whatever value available in /usr/share/zoneinfo
```
