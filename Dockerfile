FROM crystallang/crystal:1.0.0-alpine

ENV MINIFY_JS=true

ADD . /src
WORKDIR /src

RUN apk add --update nodejs npm

RUN npm install uglify-js -g

RUN shards build --release --ignore-crystal-version
RUN ldd bin/tiktok-passport | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'

FROM scratch

COPY --from=0 /src/deps /
COPY --from=0 /src/bin/tiktok-passport /tiktok-passport

EXPOSE 3000

ENTRYPOINT ["/tiktok-passport"]
