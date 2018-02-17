## Typical Usage
```
docker run -d --name soulseek \
-v "~/.SoulseekQt":"/root/.SoulseekQt" \
-v "~/Soulseek Downloads":"/root/Soulseek Downloads" \
-p 5900:5900 \
realies/soulseek
```
Where `~/.SoulseekQt` and `~/Soulseek Downloads` are the host locations for appdata and downloads persistence.
