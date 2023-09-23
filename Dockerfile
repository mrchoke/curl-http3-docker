FROM debian:12 as base

RUN apt update \
  && apt -y install git \
  build-essential automake autoconf libtool pkg-config \
  zlib1g-dev libc-ares-dev libssl-dev libnghttp2-dev libbpf-dev clang \
  && update-ca-certificates \
  && mkdir -p /app

WORKDIR /app
ARG CC=clang
ARG CXX=clang++

RUN git clone --depth 1 -b openssl-3.0.10+quic https://github.com/quictls/openssl \
  && cd openssl \
  && ./config enable-tls1_3 no-shared --libdir=/usr/local/lib \
  && make -j$(nproc) \
  && make install_sw \
  && cd ..

RUN git clone --depth 1 https://github.com/ngtcp2/nghttp3 \
  && cd nghttp3 \
  && autoreconf -fi \
  && ./configure  --enable-lib-only --enable-static --disable-shared \
  && make -j$(nproc)  \
  && make install \
  && cd ..

RUN git clone  --depth 1  https://github.com/ngtcp2/ngtcp2 \
  && cd ngtcp2 \
  && autoreconf -fi \
  && ./configure PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/local/lib/pkgconfig LDFLAGS="-Wl,-rpath,/usr/local/lib"  --enable-lib-only --enable-static --disable-shared  \
  && make -j$(nproc) \
  && make install \
  && cd ..

RUN git clone --depth 1 https://github.com/nghttp2/nghttp2 \
  && cd nghttp2 \
  && git submodule update --init \
  && autoreconf -fi \
  && CC=clang ./configure --with-mruby --with-neverbleed --enable-http3 --with-libbpf --enable-static --disable-shared \
  && make -j$(nproc) \
  && make install \
  && cd ..


RUN git clone  --depth 1 https://github.com/curl/curl \
  && cd curl \
  && autoreconf -fi \
  && LDFLAGS="-static -L/usr/local/lib" PKG_CONFIG="pkg-config --static" \
  ./configure --with-ssl=/usr/local  \
  --with-nghttp2=/usr/local \
  --with-nghttp3=/usr/local \
  --with-ngtcp2=/usr/local \
  --disable-shared \
  --enable-alt-svc \
  --enable-static \
  --disable-ldap \
  --enable-ipv6 \
  --enable-unix-sockets \
  && make -j$(nproc) V=1 LDFLAGS="-static -all-static -L/usr/local/lib" \
  && strip /app/curl/src/curl \
  && cd ..


FROM scratch
LABEL maintainer="Supphachoke Suntiwichaya <mrchoke@gmail.com>"

COPY --from=base /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=base /app/curl/src/curl /usr/bin/curl

# ENTRYPOINT [ "/usr/bin/curl" ]
CMD [ "/usr/bin/curl", "-V" ]

