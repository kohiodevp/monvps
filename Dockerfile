FROM debian:12-slim

# Installer dépendances de build et runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \
    build-essential \
    cmake \
    pkg-config \
    libjson-c-dev \
    libwebsockets-dev \
    curl \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Créer utilisateur admin
ARG ADMIN_PASSWORD=admin
RUN useradd -ms /bin/bash admin \
    && echo "admin:$ADMIN_PASSWORD" | chpasswd \
    && adduser admin sudo

# Compiler ttyd
RUN git clone https://github.com/tsl0922/ttyd.git /tmp/ttyd \
    && cd /tmp/ttyd && mkdir build && cd build \
    && cmake .. && make && make install \
    && rm -rf /tmp/ttyd \
    && apt-get remove -y git build-essential cmake pkg-config \
    && apt-get autoremove -y \
    && apt-get clean

# Render fournit le port via $PORT
ENV PORT=10000
EXPOSE $PORT

# Passer à l'utilisateur non-root
USER admin
WORKDIR /home/admin

# Lancer ttyd avec le port dynamique
CMD ["sh", "-c", "ttyd -p $PORT -i 0.0.0.0 bash"]
