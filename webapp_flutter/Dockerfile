FROM debian:latest AS build-env

RUN apt-get update && apt-get install -y curl git unzip locales

RUN locale-gen pt_BR.UTF-8

ENV LANG=pt_BR.UTF-8
ENV LANGUAGE=pt_BR:pt
ENV LC_ALL=pt_BR.UTF-8

ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.24.4
ARG APP=/app/

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK

RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v

RUN mkdir $APP

COPY . $APP

WORKDIR $APP

RUN flutter clean
RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine

RUN apk add --no-cache bash

RUN rm -rf /usr/share/nginx/html/*

COPY --from=build-env /app/build/web /usr/share/nginx/html

COPY wait-for-it.sh /wait-for-it.sh

RUN chmod 755 /wait-for-it.sh

EXPOSE 80

CMD ["./wait-for-it.sh", "api:5000", "--", "nginx", "-g", "daemon off;"]
