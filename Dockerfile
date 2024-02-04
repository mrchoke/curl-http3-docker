FROM debian:12 as base

RUN apt update \
  && apt -y install git \
  build-essential automake autoconf libtool pkg-config \
  zlib1g-dev libc-ares-dev libssl-dev cmake libbpf-dev clang  \
  && update-ca-certificates \
  && mkdir -p /app

WORKDIR /app
ARG CC=clang
ARG CXX=clang++

RUN git clone --depth 1  -b openssl-3.2.0 https://github.com/openssl/openssl.git \
  && cd openssl \
  && ./config enable-tls1_3 --prefix=/usr/local  no-shared --libdir=/usr/local/lib '-Wl,-rpath,/usr/local/lib' disable-docs \
  && make -j$(nproc) \
  && make install_sw \
  && cd ..

RUN git clone --depth 1 https://github.com/ngtcp2/nghttp3.git \
  && cd nghttp3 \
  && autoreconf -fi \
  && git submodule update --init \
  && ./configure  --prefix=/usr/local --enable-lib-only --enable-static --disable-shared \
  && make -j$(nproc)  \
  && make install \
  && cd ..

RUN git clone --depth 1 https://github.com/nghttp2/nghttp2.git \
  && cd nghttp2 \
  && git submodule update --init \
  && autoreconf -fi \
  && ./configure --prefix=/usr/local --with-mruby --with-neverbleed --disable-http3 --with-libbpf --enable-static --disable-shared \
  && make -j$(nproc) \
  && make install \
  && cd ..

RUN git clone --depth 1 https://github.com/google/brotli.git \
  && cd brotli \
  && mkdir out \
  && cd out \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. -DBUILD_SHARED_LIBS=OFF \
  && cmake --build . --config Release --target install \
  && cd ..

RUN git clone  --depth 1 https://github.com/curl/curl.git \
  && cd curl \
  && autoreconf -fi \
  && LDFLAGS="-static -all-static -L/usr/local/lib" PKG_CONFIG="pkg-config --static" \
  ./configure \
  --with-openssl=/usr/local \
  --with-openssl-quic \
  --without-libpsl \
  --with-brotli \
  --with-nghttp3=/usr/local \
  --with-nghttp2=/usr/local \
  --disable-shared \
  --enable-alt-svc \
  --enable-static \
  --disable-ldap \
  --enable-ipv6 \
  --enable-unix-sockets \
  && make -j$(nproc) \
  && strip /app/curl/src/curl \
  && cd ..

FROM scratch
LABEL maintainer="Supphachoke Suntiwichaya <mrchoke@gmail.com>"

COPY --from=base /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=base /app/curl/src/curl /usr/bin/curl

CMD [ "/usr/bin/curl", "-V" ]

