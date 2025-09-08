#!/bin/bash
# Démarrer Webmin
service webmin start

# Démarrer Nginx
nginx

# Démarrer ttyd sur port 10002
ttyd -p 10002 -i 0.0.0.0 bash &

# Garder le container actif
tail -f /dev/null
