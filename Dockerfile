FROM geonetwork:4.4.7

COPY ./jetty/http-forwarded.ini /var/lib/jetty/start.d/http-forwarded.ini