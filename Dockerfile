FROM debian:12-slim

# Installer dépendances
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    apt-transport-https \
    software-properties-common \
    sudo \
    perl \
    libnet-ssleay-perl \
    libauthen-pam-perl \
    libio-pty-perl \
    unzip \
    curl \
    git \
    build-essential \
    cmake \
    pkg-config \
    libjson-c-dev \
    libwebsockets-dev \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Créer utilisateur admin
ARG ADMIN_PASSWORD=admin
RUN useradd -ms /bin/bash admin \
    && echo "admin:$ADMIN_PASSWORD" | chpasswd \
    && adduser admin sudo

# Installer Webmin
RUN wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add - \
    && echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list \
    && apt-get update && apt-get install -y webmin \
    && rm -rf /var/lib/apt/lists/*

# Config Webmin interne (port 10001)
RUN sed -i 's/port=10000/port=10001/g' /etc/webmin/miniserv.conf \
    && echo "allow=0.0.0.0/0" >> /etc/webmin/miniserv.conf

# Compiler ttyd
RUN git clone https://github.com/tsl0922/ttyd.git /tmp/ttyd \
    && cd /tmp/ttyd && mkdir build && cd build \
    && cmake .. && make && make install \
    && rm -rf /tmp/ttyd

# Config Nginx
RUN rm /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Render impose $PORT
ENV PORT=10000
EXPOSE 10000

# Script de démarrage
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
