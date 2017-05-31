FROM openresty/openresty:latest-trusty

ENV DEBIAN_FRONTEND noninteractive

# Install redis tools locally + other goodies
RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends -yqq \
     dnsmasq \
     redis-tools \
     vim \
     dnsutils \
    && apt-get clean autoclean \
    && apt-get autoremove -y

# Add NGINX lua libraries
RUN mkdir -p /usr/local/openresty/lualib/revelatio/
ADD ./lualib/revelatio/*.lua /usr/local/openresty/lualib/revelatio/
#ADD ./lualib/resty/*.lua /usr/local/openresty/lualib/resty/

# Add NGINX config
ADD ./docroot/ /usr/local/openresty/nginx/html
ADD ./conf/nginx/ /etc/nginx/
ADD ./conf/dnsmasq/dnsmasq.conf /etc/dnsmasq.conf
ADD ./start /usr/local/openresty/bin/
RUN chmod a+x /usr/local/openresty/bin/start

# TODO SSL
# ADD ./docker/ssl/* /etc/nginx/ssl/

EXPOSE 53 80 443

ENTRYPOINT ["/usr/local/openresty/bin/start"]
