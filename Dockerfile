FROM ubuntu:20.04

WORKDIR /var/www

RUN set -ex; \
    apt-get update && apt-get upgrade -y; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      apache2 \
      ca-certificates \
      curl \
      less \
      libapache2-mod-php7.4 \
      php-imagick \
      php7.4 \
      php7.4-common \
      php7.4-curl \
      php7.4-gd \
      php7.4-json \
      php7.4-mbstring \
      php7.4-mysql \
      php7.4-xml \
      php7.4-zip \
    ; \
    apt-get clean && apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*

# Setup MPM environment values used in entrypoint.sh
ENV APACHE_MPM_STARTSERVERS=5
ENV APACHE_MPM_MINSPARESERVERS=1
ENV APACHE_MPM_MAXSPARESERVERS=5
ENV APACHE_MPM_MAXREQUESTWORKERS=5
ENV APACHE_MPM_MAXCONNICTIONSPERCHILD=2000

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

# generically convert lines like
#   export APACHE_RUN_USER=www-data
# into
#   : ${APACHE_RUN_USER:=www-data}
#   export APACHE_RUN_USER
# so that they can be overridden at runtime ("-e APACHE_RUN_USER=...")
RUN sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' /etc/apache2/envvars

# Adjust pid file location
ENV APACHE_PID_FILE=/tmp/apache2.pid

# Log to stdout/stderr considering write permissions on forked processes running with user other than root
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log && \
    ln -sf /dev/null /var/log/apache2/other_vhosts_access.log

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

# Enable apache mods
RUN a2enmod authz_core deflate expires headers mime rewrite setenvif

# Set DocumentRoot
RUN sed 's:/var/www/html:/var/www/application:' -i /etc/apache2/sites-available/000-default.conf

# Copy configs
COPY dockerconfig/conf.d/* /etc/apache2/conf-available/
RUN a2enconf internetexplorer mime performance security wordpress

COPY dockerconfig/php.ini /etc/php/7.4/apache2/

COPY dockerconfig/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Setup wp-cli
RUN curl -Ls -o /usr/local/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v2.4.0/wp-cli-2.4.0.phar
COPY dockerconfig/SHA512SUMS /tmp/SHA512SUMS
RUN sha512sum --check --strict /tmp/SHA512SUMS
RUN chmod +x /usr/local/bin/wp

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["apachectl", "-D", "FOREGROUND"]
