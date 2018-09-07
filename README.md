![](https://i.snag.gy/8dpAbV.jpg)

## Typical Usage

##### Using Docker CLI
```
docker run -d --name soulseek --restart=always \
-v "/persistent/appdata":"/root/.SoulseekQt" \
-v "/persistent/logs":"/root/Soulseek Chat Logs" \
-v "/persistent/downloads":"/root/Soulseek Downloads" \
-e resolution=1280x720 \
-p 6080:6080 \
realies/soulseek
```

##### Using Docker Compose
```
docker-compose up -d
```
