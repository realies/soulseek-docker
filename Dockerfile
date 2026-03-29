# ===== Stage 1: Download and prepare external artifacts =====
FROM ubuntu:latest AS downloader

ARG TARGETARCH

ARG SOULSEEKQT_VERSION=2024-6-30
ARG BOX64_GPG_FINGERPRINT=32F9ECBF8E64E9C22F95AEB34DBE689F87D192A5

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl xz-utils patch \
    $([ "$TARGETARCH" = "amd64" ] && echo "binutils" || true) \
    $([ "$TARGETARCH" = "arm64" ] && echo "squashfs-tools" || true) && \
    rm -rf /var/lib/apt/lists/*

# Download s6-overlay
RUN case "$TARGETARCH" in \
      amd64) S6_ARCH="x86_64" ;; \
      arm64) S6_ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac && \
    mkdir -p /staging && \
    curl -fL# https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-noarch.tar.xz -o /tmp/s6-overlay-noarch.tar.xz && \
    tar -C /staging -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    curl -fL# "https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-${S6_ARCH}.tar.xz" -o /tmp/s6-overlay-arch.tar.xz && \
    tar -C /staging -Jxpf /tmp/s6-overlay-arch.tar.xz && \
    rm -rf /tmp/*

# Download, verify, and extract SoulseekQt (dynamic squashfs offset detection for arm64)
RUN curl -fL# "https://f004.backblazeb2.com/file/SoulseekQt/SoulseekQt-${SOULSEEKQT_VERSION}.AppImage" -o /tmp/SoulseekQt.AppImage && \
    echo "332d9369f0746f1fdd72c77027915983a155165800c9fab991c110601a870f3b  /tmp/SoulseekQt.AppImage" | sha256sum -c - && \
    if [ "$TARGETARCH" = "amd64" ]; then \
      chmod +x /tmp/SoulseekQt.AppImage && \
      /tmp/SoulseekQt.AppImage --appimage-extract && \
      mv /squashfs-root /staging/app && \
      strip /staging/app/SoulseekQt; \
    else \
      OFFSET=$(grep -abo 'hsqs' /tmp/SoulseekQt.AppImage | tail -1 | cut -d: -f1) && \
      [ -n "$OFFSET" ] || { echo "Could not find squashfs header in AppImage" >&2; exit 1; } && \
      tail -c +$((OFFSET + 1)) /tmp/SoulseekQt.AppImage > /tmp/appimage.squashfs && \
      unsquashfs -d /staging/app /tmp/appimage.squashfs && \
      mv /staging/app/SoulseekQt /staging/app/SoulseekQt.x86_64 && \
      printf '#!/bin/bash\nexport BOX64_LD_LIBRARY_PATH=/app/lib:${BOX64_LD_LIBRARY_PATH:-}\nexport BOX64_LOG=0\nexec box64 /app/SoulseekQt.x86_64 "$@"\n' > /staging/app/SoulseekQt && \
      chmod +x /staging/app/SoulseekQt; \
    fi && \
    rm -rf /tmp/*

# Download and prepare noVNC + websockify + icons
COPY ui.patch /tmp/
RUN mkdir -p /staging/usr/share/novnc && \
    curl -fL# https://github.com/novnc/noVNC/archive/master.tar.gz -o /tmp/novnc.tar.gz && \
    tar -xf /tmp/novnc.tar.gz --strip-components=1 -C /staging/usr/share/novnc && \
    mkdir -p /staging/usr/share/novnc/utils/websockify && \
    curl -fL# https://github.com/novnc/websockify/archive/master.tar.gz -o /tmp/websockify.tar.gz && \
    tar -xf /tmp/websockify.tar.gz --strip-components=1 -C /staging/usr/share/novnc/utils/websockify && \
    curl -fL# https://raw.githubusercontent.com/FortAwesome/Font-Awesome/refs/heads/6.x/svgs/solid/cloud-arrow-down.svg -o /staging/usr/share/novnc/app/images/downloads.svg && \
    curl -fL# https://raw.githubusercontent.com/FortAwesome/Font-Awesome/refs/heads/6.x/svgs/solid/folder.svg -o /staging/usr/share/novnc/app/images/shared.svg && \
    curl -fL# https://raw.githubusercontent.com/FortAwesome/Font-Awesome/refs/heads/6.x/svgs/solid/comments.svg -o /staging/usr/share/novnc/app/images/logs.svg && \
    bash -c 'sed -i "s/<path/<path style=\"fill:white\"/" /staging/usr/share/novnc/app/images/{downloads,logs,shared}.svg' && \
    patch /staging/usr/share/novnc/vnc.html < /tmp/ui.patch && \
    sed -i 's/10px 0 5px/8px 0 6px/' /staging/usr/share/novnc/app/styles/base.css && \
    rm -rf /tmp/*

# ===== Stage 2: Runtime image =====
FROM ubuntu:latest

ARG TARGETARCH
ARG BOX64_GPG_FINGERPRINT=32F9ECBF8E64E9C22F95AEB34DBE689F87D192A5

# python3 is needed by websockify; python3-numpy (amd64) improves websockify HyBi performance
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates fonts-noto-cjk locales libegl1 openbox python3 \
    tigervnc-standalone-server tigervnc-tools tzdata \
    $([ "$TARGETARCH" = "amd64" ] && echo "python3-numpy" || true) \
    $([ "$TARGETARCH" = "arm64" ] && echo "gnupg wget \
    libxcb-render0 libxcb-render-util0 libxcb-xkb1 libxcb-icccm4 libxcb-image0 \
    libxcb-keysyms1 libxcb-randr0 libxcb-shape0 libxcb-sync1 libxcb-xfixes0 \
    libxcb-cursor0 libxkbcommon0 libxkbcommon-x11-0" || true) && \
    locale-gen en_US.UTF-8 && \
    # Install Box64 for arm64 x86_64 emulation with GPG fingerprint verification
    if [ "$TARGETARCH" = "arm64" ]; then \
      mkdir -p /usr/share/keyrings && \
      wget -qO /tmp/box64.gpg "https://Pi-Apps-Coders.github.io/box64-debs/KEY.gpg" && \
      ACTUAL_FP=$(gpg --batch --import-options show-only --import --with-colons /tmp/box64.gpg 2>/dev/null | awk -F: '/^fpr/{print $10; exit}') && \
      [ "$ACTUAL_FP" = "${BOX64_GPG_FINGERPRINT}" ] || \
        { echo "Box64 GPG key fingerprint mismatch: expected ${BOX64_GPG_FINGERPRINT}, got $ACTUAL_FP" >&2; exit 1; } && \
      gpg --dearmor < /tmp/box64.gpg > /usr/share/keyrings/box64-archive-keyring.gpg && \
      rm -f /tmp/box64.gpg && \
      printf 'Types: deb\nURIs: https://Pi-Apps-Coders.github.io/box64-debs/debian\nSuites: ./\nSigned-By: /usr/share/keyrings/box64-archive-keyring.gpg\n' > /etc/apt/sources.list.d/box64.sources && \
      apt-get update && \
      apt-get install -y --no-install-recommends box64-generic-arm && \
      apt-get purge -y gnupg wget && \
      apt-get autoremove -y; \
    fi && \
    rm -rf /var/lib/apt/lists/*

# Copy prepared artifacts from downloader stage
COPY --from=downloader /staging/ /

# Symlinks and user setup
RUN ln -s /app/default.png /usr/share/novnc/app/images/soulseek.png && \
    ln -s "/data/Soulseek Downloads" /usr/share/novnc/downloads && \
    ln -s "/data/Soulseek Shared Folder" /usr/share/novnc/shared && \
    ln -s "/data/Soulseek Chat Logs" /usr/share/novnc/logs && \
    if getent passwd 1000 > /dev/null 2>&1; then \
      userdel -f "$(getent passwd 1000 | cut -d: -f1)"; \
    fi && \
    if getent group 1000 > /dev/null 2>&1; then \
      groupdel -f "$(getent group 1000 | cut -d: -f1)"; \
    fi && \
    rm -rf /home && \
    useradd -u 1000 -U -d /data -s /bin/false soulseek && \
    usermod -G users soulseek && \
    mkdir /data

ENV DISPLAY=:1 \
    HOME=/tmp \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    VNC_PORT=5900 \
    NOVNC_PORT=6080 \
    PGID=1000 \
    PUID=1000 \
    UMASK=022 \
    MODIFY_VOLUMES=true \
    XDG_RUNTIME_DIR=/tmp

COPY rootfs /

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD python3 -c "import os, socket, urllib.request; urllib.request.urlopen('http://127.0.0.1:' + os.environ.get('NOVNC_PORT', '6080') + '/', timeout=4); socket.create_connection(('127.0.0.1', int(os.environ.get('VNC_PORT', '5900'))), timeout=4).close()"

ENTRYPOINT ["/init"]
