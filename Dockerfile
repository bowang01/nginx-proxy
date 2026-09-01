FROM nginx:alpine
RUN apk add --no-cache gettext certbot
COPY nginx.conf /etc/nginx/nginx.conf
COPY 00-default.conf /etc/nginx/tpl/00-default.conf
COPY http.conf.template ssl.conf.template /etc/nginx/tpl/
COPY start.sh /start.sh
RUN chmod +x /start.sh \
    && rm -f /etc/nginx/conf.d/default.conf \
    && mkdir -p /var/www/certbot /etc/nginx/conf.d
ENTRYPOINT ["/start.sh"]
