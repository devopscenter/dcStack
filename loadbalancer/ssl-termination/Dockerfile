FROM nginx:1.7.7

MAINTAINER josh@devops.center

ADD nginx.conf /etc/nginx/nginx.conf

ADD ./ssl.key /etc/nginx/ssl/
ADD ./ssl.crt /etc/nginx/ssl/

RUN mkdir -p /etc/nginx/logs
