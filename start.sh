#!/bin/sh
set -e

SITES="${SITES:-lota}"
ACME_EMAIL="${ACME_EMAIL:-}"

site_upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

site_value() {
    upper=$(site_upper "$1")
    eval echo "\$${upper}_$2"
}

render_sites() {
    rm -f /etc/nginx/conf.d/*.conf
    cp /etc/nginx/tpl/00-default.conf /etc/nginx/conf.d/00-default.conf

    for site in ${SITES}; do
        domain=$(site_value "$site" DOMAIN)
        aliases=$(site_value "$site" ALIASES)
        upstream=$(site_value "$site" UPSTREAM)

        if [ -z "$domain" ] || [ -z "$upstream" ]; then
            echo "Skip site ${site}: DOMAIN or UPSTREAM is empty."
            continue
        fi

        DOMAIN="$domain"
        DOMAIN_ALIASES="$aliases"
        UPSTREAM="$upstream"
        export DOMAIN DOMAIN_ALIASES UPSTREAM

        if [ -f "/etc/letsencrypt/live/${domain}/fullchain.pem" ]; then
            envsubst '${DOMAIN} ${DOMAIN_ALIASES} ${UPSTREAM}' \
                < /etc/nginx/tpl/ssl.conf.template > /etc/nginx/conf.d/${site}.conf
        else
            envsubst '${DOMAIN} ${DOMAIN_ALIASES} ${UPSTREAM}' \
                < /etc/nginx/tpl/http.conf.template > /etc/nginx/conf.d/${site}.conf
        fi
    done
}

request_certs() {
    if [ -z "$ACME_EMAIL" ]; then
        echo "ACME_EMAIL is not set. Let's Encrypt is skipped."
        return
    fi

    echo "Waiting for nginx before requesting certificates..."
    sleep 25

    while true; do
        for site in ${SITES}; do
            domain=$(site_value "$site" DOMAIN)
            aliases=$(site_value "$site" ALIASES)

            if [ -z "$domain" ]; then
                continue
            fi

            echo "Running certbot for ${domain} ${aliases}..."
            CERTBOT_DOMAINS="-d ${domain}"
            for extra in ${aliases}; do
                CERTBOT_DOMAINS="${CERTBOT_DOMAINS} -d ${extra}"
            done

            if certbot certonly \
                --webroot \
                --webroot-path /var/www/certbot \
                ${CERTBOT_DOMAINS} \
                --email "$ACME_EMAIL" \
                --agree-tos \
                --no-eff-email \
                --keep-until-expiring \
                --non-interactive \
                --expand; then
                echo "Certificate is ready for ${domain}."
            else
                echo "certbot failed for ${domain}."
            fi
        done
        sleep 12h
    done
}

mkdir -p /var/www/certbot /etc/nginx/conf.d
render_sites

(
    while true; do
        sleep 20
        render_sites
        nginx -s reload >/dev/null 2>&1 || true
    done
) &

(
    request_certs
) &

exec nginx -g "daemon off;"
