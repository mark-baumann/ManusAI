# Manus AI Dockerfile – stabil für Intel Macs (amd64)
FROM --platform=linux/amd64 ubuntu:22.04

# Vermeide interaktive Prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV HOSTNAME=sandbox

# Aliyun Mirrors für schnellere Updates
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list

# 1️⃣ Basis-Tools Schrittweise installieren
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common || true
RUN apt-get install -y --no-install-recommends sudo || true
RUN apt-get install -y --no-install-recommends bc curl wget gnupg dirmngr || true
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 2️⃣ GUI / VNC / Supervisor
RUN apt-get update && apt-get install -y --no-install-recommends xvfb xterm socat supervisor x11vnc || true
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Benutzer 'ubuntu' erstellen
RUN useradd -m -d /home/ubuntu -s /bin/bash ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu

# Python 3.10 über deadsnakes PPA
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update && apt-get install -y --no-install-recommends python3.10 python3.10-venv python3.10-dev python3.10-distutils curl wget || true
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# pip für Python 3.10 installieren
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Websockify installieren
RUN python3 -m pip install --no-cache-dir websockify

# Node.js 20
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install -y --no-install-recommends nodejs
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN npm config set registry https://registry.npmmirror.com

# Google Chrome installieren
RUN add-apt-repository ppa:xtradeb/apps -y || true
RUN apt-get update && apt-get install -y --no-install-recommends chromium
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Fonts und Locale
RUN apt-get update && apt-get install -y --no-install-recommends fonts-noto-cjk fonts-noto-color-emoji language-pack-zh-hans locales
RUN locale-gen zh_CN.UTF-8
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Arbeitsverzeichnis
WORKDIR /app

# Python-Abhängigkeiten installieren
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Restliche Projektdateien kopieren
COPY . .

# Supervisor konfigurieren
COPY supervisord.conf /etc/supervisor/conf.d/app.conf

# Ports
EXPOSE 8080 9222 5900 5901

ENV UVI_ARGS=""
ENV CHROME_ARGS=""

# Supervisor starten
CMD ["supervisord", "-n", "-c", "/app/supervisord.conf"]
