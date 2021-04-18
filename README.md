# Tiktok Passport

Unpretentious ~6mb docker image that signs Tiktok requests. For now it works
for my use case, which is a rather polyglot codebase.

You will have to spin up a pool of selenium instances. You might want use a
residential proxy as well.

## Minimal setup

```
docker run -e SELENIUM_BROWSER_URL="http://localhost:4444/wd/hub" tiktok-passport:1.0.0
```

## Compose

```yml
services:
  tiktok-passport:
    image: tiktok-passport:1.0.0
    environment:
      SELENIUM_BROWSER_URL: "http://chrome:4444/wd/hub"
    ports:
      - 3000:3000
    depends_on:
      chrome:
        condition: service_healthy

  chrome:
    image: selenium/standalone-chrome
    environment:
      SE_NODE_MAX_SESSIONS: 12
      SE_NODE_OVERRIDE_MAX_SESSIONS: "true"
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

```
curl -X POST -d https://m.tiktok.com/api/post/item_list/?aid=1988&secUid=REPLACE&count=30&cursor=0 http://localhost:3000
```

Expected response:

```json
{
  "status": "ok",
  "data": {
    "signed_at": 1218723927472,
    "user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1",
    "signature": "_02B4Z6wo00f01uM-IxAABIDBGcu.-.8HuWrjDweAANjB7e",
    "verify_fp": "verify_kmmub8vz_4xImC2zP_AIIB_4lmW_Brwf_Zlr9yhk387F2",
    "signed_url": "https://m.tiktok.com/api/post/item_list/?aid=1988&secUid=REPLACE&count=30&cursor=0&verifyFp=verify_kmmub8vz_4xImC2zP_AIIB_4lmW_Brwf_Zlr9yhk387F2&_signature=_02B4Z6wo00f01uM-IxAABIDBGcu.-.8HuWrjDweAANjB7e"
  }
}
```
