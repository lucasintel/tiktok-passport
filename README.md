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
  - `USER_AGENT`
  - `PORT`

## Example

```
curl -X POST -d http://tiktok.com/my-request http://localhost:3000
```

Expected response:

```json
{
  "status": "ok",
  "data": {
    "signed_at": 1218723927472,
    "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537[...]",
    "signature": "_02B4Z6wo00f01uM-IxAABIDBGcu.-.8HuWrjDweAANjB7e",
    "verify_fp": "verify_kmmub8vz_4xImC2zP_AIIB_4lmW_Brwf_Zlr9yhk387F2",
    "signed_url": "http://tiktok.com/my-request?verifyFp=[...]&_signature=[...]"
  }
}
```
