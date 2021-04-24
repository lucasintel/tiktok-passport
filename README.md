# Tiktok Passport

Minimal (really, 6 megabytes) docker image that signs Tiktok requests. For now,
it works for my use case. You will have to spin up a pool of selenium
instances.

Tiktok Passport automatically recovers from connection-related failures with
the remote browser. Just make sure to monitor and restart unhealthy/crashed
selenium instances.

To prevent detection, [evasion strategies](https://github.com/kandayo/tiktok-passport/tree/main/src/tiktok_passport/marionette/javascript/evasions)
ported from `puppeteer-extra-plugin-stealth` are included. You can find the
stealth test at the examples folder.

## Minimal setup

```yml
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
    restart: "always"
    environment:
      SE_NODE_MAX_SESSIONS: 12
      SE_NODE_OVERRIDE_MAX_SESSIONS: "true"
      SE_NODE_SESSION_TIMEOUT: 86400
    healthcheck:
      test: "/opt/bin/check-grid.sh --host 0.0.0.0 --port 4444"
      interval: 5s
      timeout: 30s
      retries: 5
```

## Environment variables

  - `POOL_CAPACITY`
  - `POOL_TIMEOUT`
  - `SELENIUM_BROWSER_URL`
  - `PORT`

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
