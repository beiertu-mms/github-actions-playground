FROM azul/zulu-openjdk-alpine:11.0.9-jre
LABEL MAINTAINER=beiertu@mediamarktsaturn.com

USER root

RUN apk --no-cache add tzdata ca-certificates && \
    cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    echo "Europe/Berlin" >  /etc/timezone && \
    addgroup -S cos && adduser -S -G cos cos

COPY app.jar app.jar

USER cos

ENTRYPOINT ["java","-jar","app.jar"]
