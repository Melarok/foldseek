ARG BUILDPLATFORM=linux/amd64
FROM --platform=$BUILDPLATFORM debian:stable-backports as builder
ARG TARGETARCH=amd64
ARG APP=foldseek
ARG INSTRUCTIONSET=avx2

RUN if [ "$TARGETARCH" = "amd64" ]; then \
       dpkg --add-architecture $TARGETARCH \
       && apt-get update \
       && apt-get install -y \
         build-essential curl xxd git cmake \
         zlib1g-dev libbz2-dev libatomic1 \
       && rm -rf /var/lib/apt/lists/*; \
     else \
       dpkg --add-architecture $TARGETARCH \
       && apt-get update \
       && apt-get install -y \
         build-essential curl xxd git cmake \
         zlib1g-dev libbz2-dev libatomic1 \
         crossbuild-essential-$TARGETARCH zlib1g-dev:$TARGETARCH libbz2-dev:$TARGETARCH \
       && rm -rf /var/lib/apt/lists/*; \
     fi

RUN if [ "$TARGETARCH" = "arm64" ]; then \
      ARCH=aarch64; \
    else \
      ARCH=x86_64; \
    fi; \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
      sh -s -- --profile minimal --default-host ${ARCH}-unknown-linux-gnu -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /opt/build
ADD . .

RUN threads=$(($(nproc) / 4)); \
    if [ "$TARGETARCH" = "arm64" ]; then \
      mkdir -p build_$TARGETARCH/src; \
      cd /opt/build/build_$TARGETARCH; \
      CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++ cmake -DHAVE_ARM8=1 -DHAVE_MPI=0 -DHAVE_TESTS=0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=. ..; \
      make -j$threads; \
      mv src/${APP} /opt/build/${APP}_arch; \
      touch /opt/build/${APP}_sse2 /opt/build/${APP}_avx2; \
    else \
      if [ "$INSTRUCTIONSET" = "sse2" ]; then \
        mkdir -p build_sse2/src; \
        cd /opt/build/build_sse2; \
        cmake -DHAVE_SSE2=1 -DHAVE_MPI=0 -DHAVE_TESTS=0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=. ..; \
        make -j$threads; \
        mv src/${APP} /opt/build/${APP}_sse2; \
        touch /opt/build/${APP}_arch; \
      elif [ "$INSTRUCTIONSET" = "avx2" ]; then \
        mkdir -p build_avx2/src; \
        cd /opt/build/build_avx2; \
        cmake -DHAVE_AVX2=1 -DHAVE_MPI=0 -DHAVE_TESTS=0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=. ..; \
        make -j$threads; \
        mv src/${APP} /opt/build/${APP}_avx2; \
        touch /opt/build/${APP}_arch; \
      else \
       mkdir -p build_sse2/src && mkdir -p build_avx2/src; \
        cd /opt/build/build_sse2; \
        cmake -DHAVE_SSE2=1 -DHAVE_MPI=0 -DHAVE_TESTS=0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=. ..; \
        make -j$threads; \
        mv src/${APP} /opt/build/${APP}_sse2; \
        cd /opt/build/build_avx2; \
        cmake -DHAVE_AVX2=1 -DHAVE_MPI=0 -DHAVE_TESTS=0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=. ..; \
        make -j$threads; \
        mv src/${APP} /opt/build/${APP}_avx2; \
        touch /opt/build/${APP}_arch; \
      fi; \
    fi

FROM debian:stable-slim
ARG TARGETARCH
ARG APP=foldseek

RUN apt-get update && apt-get install -y \
      gawk bash grep libstdc++6 libgomp1 libatomic1 zlib1g libbz2-1.0 wget tar aria2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/build/${APP}_* /usr/local/bin/
ADD utils/foldseekRun.sh /usr/local/bin/entrypoint
RUN if [ "$TARGETARCH" = "arm64" ]; then rm -f /usr/local/bin/entrypoint; ln -s /usr/local/bin/${APP}_arch /usr/local/bin/entrypoint; fi

ENTRYPOINT ["/usr/local/bin/entrypoint"]
