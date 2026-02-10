# 后端 Dockerfile（使用已编译好的 jar）

FROM eclipse-temurin:17-jre-alpine

RUN apk add --no-cache netcat-openbsd tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

WORKDIR /app

# 复制已编译的 jar 包
COPY app.jar /app/app.jar

RUN mkdir -p /app/uploads /app/logs

EXPOSE 8080

ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD nc -z localhost 8080 || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
