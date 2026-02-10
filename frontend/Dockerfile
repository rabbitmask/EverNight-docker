# 前端 Dockerfile（使用已构建好的 dist）

FROM nginx:1.24-alpine

RUN rm -rf /usr/share/nginx/html/* && \
    rm /etc/nginx/conf.d/default.conf

COPY ./ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 7666

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:7666/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
