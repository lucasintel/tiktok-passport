# TikTok Passport

Minimal (shipped as a 6MB docker image), high-performance service that signs
TikTok API requests. It might work for you if you need to scale the signature
server separately, or if you have multiple services that interact with TikTok
API.

You will have to spin up a pool of selenium instances.

 - To prevent headless browser detection, TikTok Passport applies evasion
   strategies ported from `puppeteer-extra-plugin-stealth` and `selenium-stealth`.
   You can find the stealth test at the examples folder.

 - TikTok Passport automatically recovers from connection-related failures with
   the remote browser. Just make sure to monitor and restart unhealthy/crashed
   selenium instances.

## Minimal setup

```yml
version: "3.8"

services:
  tiktok-passport:
    build:
      context: .
      dockerfile: Dockerfile
    image: tiktok-passport:0.3.0
    environment:
      SELENIUM_BROWSER_URL: "http://chrome:4444/wd/hub"
    ports:
      - 3000:3000
    depends_on:
      chrome:
        condition: service_healthy

  chrome:
    image: selenium/standalone-chrome:90.0.4430.85
    environment:
      SE_NODE_MAX_SESSIONS: 12
      SE_NODE_OVERRIDE_MAX_SESSIONS: "true"
      SE_NODE_SESSION_TIMEOUT: 86400
      SCREEN_WIDTH: 1920
      SCREEN_HEIGHT: 1080
      START_XVFB: "false"
    volumes:
      - /dev/shm:/dev/shm
    healthcheck:
      test: "/opt/bin/check-grid.sh --host 0.0.0.0 --port 4444"
      interval: 15s
      timeout: 30s
      retries: 5
```

## Environment variables

```
POOL_CAPACITY=1        # Maximum amount of Selenium sessions in the pool. (Default: 1)
POOL_TIMEOUT=5         # Seconds to wait before timeout while doing a checkout. (Default: 5 seconds)
SELENIUM_BROWSER_URL=  # Remote browser URL. Required.
PORT=3000              # Port to listen to. (Default: 3000)
```

## Example

### Request:

```
curl -X POST \
     -H "Content-type: application/json" \
     -d '{"url": "https://m.tiktok.com/api/post/item_list/?aid=1988&secUid=SECUID&count=30&cursor=0"}' \
     http://localhost:3000
```

### Response

```json
{
  "status": "ok",
  "data":{
    "signed_at": 1619243929467,
    "signature": "_02B4Z6wo00f01oiMkTwAOIBGG5Gn74kktFaIjbWAAMKsaf",
    "verify_fp": "verify_knvc19xz_GHZpp3IL_sSnf_4ZTf_AZfo_FNbSIOPCkS00",
    "signed_url": "https://m.tiktok.com/api/post/item_list/?aid=1988&secUid=SECUID&count=30&cursor=0&verifyFp=verify_knvc19xz_GHZpp3IL_sSnf_4ZTf_AZfo_FNbSIOPCkS00&_signature=_02B4Z6wo00f01oiMkTwAOIBGG5Gn74kktFaIjbWAAMKsaf",
    "navigator":{
      "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (Windows NT 10.0; Win64; x64) Chrome/88.0.4324.96 Safari/537.36",
      "browser_name": "Mozilla",
      "browser_version": "5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (Windows NT 10.0; Win64; x64) Chrome/88.0.4324.96 Safari/537.36",
      "browser_language": "en-US",
      "browser_platform": "Win32",
      "screen_width": 1920,
      "screen_height": 1080
    }
  }
}
```

## As a library

```cr
require "tiktok-passport"

pool = TiktokPassport::Marionette::Pool.new("http://chrome:4444/wd/hub", 5)

uri = URI.new(
  scheme: "https",
  host: YourApp.config.tiktok_host,
  path: "/api/post/item_list/",
  query: URI::Params.build do |query|
    query.add("aid", "1988")
    query.add("secUid", "MS4wLjABAAAAv7iSuuXDJGDvJkmH_vz1qkDZYo1apxgzaxdBSeIuPiM")
    query.add("count", 30)
    query.add("cursor", "1571445154000")
    # [...]
  end
)

pool.with do |session|
  signed_request = session.sign(uri.to_s)
  puts signed_request.signed_url # => Use this URL to perform the request.
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kandayo/tiktok-passport.

1. Fork it (<https://github.com/kandayo/tiktok-passport/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [kandayo](https://github.com/kandayo) - creator and maintainer

## License

The lib is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
