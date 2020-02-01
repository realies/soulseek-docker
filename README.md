![](https://i.snag.gy/8dpAbV.jpg)

## Typical Usage

##### Using Docker Compose
```
docker-compose up -d
```

##### Using Docker CLI
```
docker run -d --name soulseek --restart=always \
-v "/persistent/appdata":"/root/.SoulseekQt" \
-v "/persistent/logs":"/root/Soulseek Chat Logs" \
-v "/persistent/downloads":"/root/Soulseek Downloads" \
-e resize=scale \
-e resolution=1280x720 \
-p 6080:6080 \
realies/soulseek
```

##### Configuration Parameters
```
resize        optional, set the novnc resize mode, defaults to scale, can be:
                  auto      honour browser's local storage
                  scale     scale the session to the browser window size
                  remote    scale the session to the remote session size
resolution    optional, set the xvfb resolution, defaults to 1280x720
```
