# cURL http3 enabled

## Official Repo

https://hub.docker.com/r/mrchoke/curl-http3

## How to use

### Test
```
docker run --rm -it  mrchoke/curl-http3
```
#### Output

```
curl 8.6.1-DEV (aarch64-unknown-linux-gnu) libcurl/8.6.1-DEV OpenSSL/3.2.0 zlib/1.2.13 brotli/1.1.0 nghttp2/1.60.0-DEV nghttp3/1.2.0-DEV
Release-Date: [unreleased]
Protocols: dict file ftp ftps gopher gophers http https imap imaps ipfs ipns mqtt pop3 pop3s rtsp smb smbs smtp smtps telnet tftp
Features: alt-svc AsynchDNS brotli HSTS HTTP2 HTTP3 HTTPS-proxy IPv6 Largefile libz NTLM SSL threadsafe TLS-SRP UnixSockets
```

### Use

```
docker run --rm -it  mrchoke/curl-http3 curl -I --http3 https://www.w3.org
```

#### Output

```
HTTP/3 200
date: Sat, 23 Sep 2023 20:43:53 GMT
content-type: text/html; charset=UTF-8
cache-control: proxy-revalidate, public, s-maxage=600
etag: "1cd6dcb612a3b5324ee5bd2306981f8b"
x-strata-cache-tags: global,homepage,blogListing,pressReleasesListing,eventsListing,newsListing,ecosystemsLandingPage,blogPosts,newsArticles,pressReleases,members
x-frontend-content: PUBLISHED
vary: Origin
x-backend: sf-frontend
x-request-id: 80b591f75ea8042a
strict-transport-security: max-age=15552000; includeSubdomains; preload
content-security-policy: frame-ancestors 'self' https://cms.w3.org/; upgrade-insecure-requests
cf-cache-status: HIT
set-cookie: __cf_bm=4aWJ24284jVQ7S.0WbdEM0N8QFXkXLAaavh_aXu1EYI-1695501833-0-Ad/hSWgHprrjystVg+l7KU5UPR2E6EoBs2pnw6NDlthaDWO+djCESOXpcuEusZlqa0BbKImM5h77GFQlV70f68A=; path=/; expires=Sat, 23-Sep-23 21:13:53 GMT; domain=.w3.org; HttpOnly; Secure; SameSite=None
server: cloudflare
cf-ray: 80b59f58eccc3f5a-SIN
alt-svc: h3=":443"; ma=86400
```

## Update

```
docker pull mrchoke/curl-http3
```

## Remove

```
docker rmi mrchoke/curl-http3
```

## How to build

### Clone

```
git clone https://github.com/mrchoke/curl-http3-docker
cd curl-http3-docker
```

### On your machine

```
docker build -t image:tag .
```

### For multiple plateform

```
docker buildx build --platform linux/amd64,linux/arm64 --push  -t your_repo/image:tag
```
