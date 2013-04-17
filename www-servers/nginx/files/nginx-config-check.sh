#!/bin/bash

NGINX_LOG=/var/log/nginx
NGINX_TMP="/var/tmp/nginx/{,client,proxy,fastcgi,scgi,uwsgi}"
USER=nginx
GROUP=nginx

/bin/mkdir -p ${NGINX_LOG} || exit 1
/bin/chown root:root ${NGINX_LOG} || exit 1
/bin/chmod 0755 ${NGINX_LOG} || exit 1

/bin/mkdir -p ${NGINX_TMP} || exit 1
/bin/chown ${USER}:${GROUP} ${NGINX_TMP} || exit 1
/bin/chmod 0755 ${NGINX_TMP} || exit 1

echo "Checking nginx' configuration"
/usr/sbin/nginx -t
