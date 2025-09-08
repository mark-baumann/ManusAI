# Nutze die native Plattform, vermeidet QEMU-Probleme
FROM --platform=$BUILDPLATFORM ubuntu:22.04 AS base

# Vermeide interaktive Eingaben
ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=sandbox

# Versuche Aliyun als Mirror, fallback auf Standard falls nicht erreichbar
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list || true && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list || true && \
    sed -i 's|http://ports.ubuntu.com/ubuntu-ports/|http://mirrors.aliyun.com/ubuntu-ports/|g' /etc/apt/sources.list || true

# Update & install Basis-Tools (ohne websockify!)
RUN apt-get update && apt-get install -y \
    sudo \
    bc \
    curl \
    wget \
    gnupg \
    software-properties-common \
    xvfb \
    x11vnc \
    xterm \
    socat \
    supervisor \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Websockify besser über pip installieren (stabiler)
RUN apt-get update && apt-get install -y python3-pip && \
    pip3 install --no-cache-dir websockify

# Benutzer anlegen
RUN useradd -m -d /home/ubuntu -s /bin/bash ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu

# Installiere Python 3.10.12 über Deadsnakes-PPA
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-venv python3.10-dev python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Konfiguriere pip auf Aliyun
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/

# Installiere Node.js 20.18.0
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
    gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
    | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# npm auf Aliyun umstellen
RUN npm config set registry https://registry.npmmirror.com

# Installiere Chromium stabiler (Fallback auf Snap falls PPA nicht geht)
RUN add-apt-repository ppa:xtradeb/apps -y && \
    apt-get update && \
    apt-get install -y chromium --no-install-recommends || \
    (apt-get install -y snapd && snap install chromium) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Fonts & Chinesische Sprachpakete
RUN apt-get update && apt-get install -y \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    language-pack-zh-hans \
    locales \
    && locale-gen zh_CN.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Dependencies zuerst kopieren (für Docker Cache)
COPY requirements.txt .

# Python Dependencies installieren
RUN pip3 install --no-cache-dir -r requirements.txt

# Restliche Projektdateien kopieren
COPY . .

# Supervisor konfigurieren
COPY supervisord.conf /etc/supervisor/conf.d/app.conf

# Ports freigeben
EXPOSE 8080 9222 5900 5901

ENV UVI_ARGS=""
ENV CHROME_ARGS=""

# Startkommando
CMD ["supervisord", "-n", "-c", "/app/supervisord.conf"]
