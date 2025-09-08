FROM debian:12-slim

# Installer dépendances
RUN apt-get update && apt-get install -y \
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
    && rm -rf /tmp/ttyd

# Render impose $PORT
ENV PORT=10000
EXPOSE 10000

# Lancer ttyd
CMD ["ttyd", "-p", "10000", "-i", "0.0.0.0", "bash"]
