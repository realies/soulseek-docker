# Soulseek Over noVNC Docker Container

![GitHub Workflow Status](https://shields.api-test.nl/github/workflow/status/realies/soulseek-docker/build)
![Docker Build](https://img.shields.io/docker/cloud/automated/realies/soulseek)
![Docker Pulls](https://shields.api-test.nl/docker/pulls/realies/soulseek)
![Docker Image Size](https://shields.api-test.nl/docker/image-size/realies/soulseek)

![](https://i.snag.gy/8dpAbV.jpg)

## Typical Usage

##### Using Docker Compose

```
docker-compose up -d
```

##### Using Docker CLI

```
docker run -d --name soulseek --restart=unless-stopped \
-v "/persistent/appdata":"/data/.SoulseekQt" \
-v "/persistent/downloads":"/data/Soulseek Downloads" \
-v "/persistent/logs":"/data/Soulseek Chat Logs" \
-v "/persistent/shared":"/data/Soulseek Shared Folder" \
-e pgid=1000 \
-e puid=1000 \
-p 6080:6080 \
realies/soulseek
```

##### Configuration Parameters

```
pgid          optional, only works if puid is set, chown app folders to the specified group id
puid          optional, only works if pgid is set, chown app folders to the specified user id, run the app with the specified user id
umask         optional, controls how file permissions are set for newly created files, defaults to 0000
vncpwd        optional, protect tigervnc with a password, none will be required if this is not set
timeZone      optional, set the local timeZone, for example:
                  Europe/Paris
                  Asia/Macao
                  America/Vancouver
                  ...other values available in /usr/share/zoneinfo
```
