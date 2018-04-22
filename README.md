![](https://i.snag.gy/RyGBbn.jpg)

## Typical Usage

##### Using Docker CLI
```
docker run -d --name soulseek --restart=always \
-v "/persistent/appdata":"/root/.SoulseekQt" \
-v "/persistent/logs":"/root/Soulseek Chat Logs" \
-v "/persistent/downloads":"/root/Soulseek Downloads" \
-p 6080:6080 \
realies/soulseek
```

##### Using Docker Compose
```
docker-compose up -d
```
