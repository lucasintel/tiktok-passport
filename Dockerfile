ARG CRYSTAL_VERSION=1.0.0
FROM crystallang/crystal:$CRYSTAL_VERSION-alpine AS build

RUN echo 'nobody:x:65534:65534:Nobody:/:' > /passwd.minimal

COPY . /src
WORKDIR /src

RUN apk add --no-cache --update nodejs npm
RUN npm install -g uglify-js

ENV MINIFY_JS=true

RUN shards build --release --ignore-crystal-version
RUN ldd bin/tiktok-passport | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'

FROM scratch
LABEL maintainer="kdy@absolab.xyz"

COPY --from=build /passwd.minimal /etc/passwd
COPY --from=build /src/deps /
COPY --from=build /src/bin/tiktok-passport /tiktok-passport

EXPOSE 3000

USER nobody

ENTRYPOINT ["/tiktok-passport"]
