FROM nginx

COPY _nginx/redirects.conf /etc/nginx/redirects.conf
COPY _nginx/blog-redirects.conf /etc/nginx/blog-redirects.conf
COPY _nginx/default.conf /etc/nginx/conf.d/default.conf

COPY docs /usr/share/mexpro

EXPOSE 80
EXPOSE 443