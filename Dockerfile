
ARG OS_VERSION=3.8

FROM alpine:${OS_VERSION} as builder
ENV UPX_VERSION=3.95
ENV LDFLAGS=-static 

# download source and compile
RUN apk add -U \
    build-base \
    ucl-dev \
    zlib-dev \
    && wget https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-src.tar.xz \
    && tar xvJf upx-${UPX_VERSION}-src.tar.xz \
    && sed -i 's/ -O2/ -O0/' /upx-${UPX_VERSION}-src/src/Makefile \
    && make -j10 -C /upx-${UPX_VERSION}-src/src upx.out CHECK_WHITESPACE=

RUN /upx-${UPX_VERSION}-src/src/upx.out \
    -9 \
    -o /usr/local/bin/upx \
    /upx-${UPX_VERSION}-src/src/upx.out

FROM alpine:${OS_VERSION}
LABEL maintainer wzshiming@foxmail.com
COPY --from=builder /usr/local/bin/upx /usr/local/bin/upx
ENTRYPOINT [ "upx" ]
