FROM ubuntu as base

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -y && apt upgrade -y
RUN apt install -y software-properties-common build-essential

RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt update
RUN apt install -y gcc-11 g++-11 clang-11 uuid-dev openssl libcrypto++-dev zlib1g-dev libc6-dev cmake xxd make libc6
RUN apt install -y git libwebsocketpp-dev libssl-dev ninja-build wget
RUN apt install -y libboost-all-dev
RUN apt install -y python

FROM base AS cpprest_builder
WORKDIR /

RUN git clone https://github.com/Microsoft/cpprestsdk.git casablanca
WORKDIR casablanca
RUN mkdir build
WORKDIR build
RUN cmake ../Release -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=0
RUN make -j4
RUN make test
RUN make install

FROM base AS libzip_builder
WORKDIR /
RUN git clone https://github.com/nih-at/libzip.git libzip
WORKDIR libzip
RUN mkdir build
WORKDIR build
RUN CC=clang-11 CXX=clang++-11 cmake .. -DBUILD_SHARED_LIBS=OFF
RUN make
RUN make test
RUN make install

FROM base AS corecrypto_builder
WORKDIR /
COPY ./corecrypto corecrypto/
WORKDIR corecrypto
RUN rm -rf build && mkdir build

WORKDIR build
RUN CC=clang-11 CXX=clang++-11 cmake .. -DCMAKE_BUILD_TYPE=Release
RUN make
RUN make install

FROM base
COPY --from=cpprest_builder /usr/local/lib/libcpprest.a /usr/local/lib/libcpprest.a
COPY --from=cpprest_builder /usr/local/include/cpprest /usr/local/include/cpprest/
COPY --from=cpprest_builder /usr/local/include/pplx /usr/local/include/pplx/
COPY --from=libzip_builder /usr/local/lib/libzip.a /usr/local/lib/libzip.a
COPY --from=corecrypto_builder /usr/local/lib/libcorecrypto_static.a /usr/local/lib/libcorecrypto_static.a
COPY --from=corecrypto_builder /usr/local/include/corecrypto /usr/local/include/corecrypto/

RUN mkdir /AltServer-Linux

WORKDIR /AltServer-Linux

COPY ./libraries /AltServer-Linux/libraries/
COPY ./src /AltServer-Linux/src/
COPY ./Makefile /AltServer-Linux/Makefile
RUN CC=clang-11 CXX=clang++-11 make NO_USBMUXD_STUB=1 NO_UPNP_STUB=1 -j6
RUN CC=clang-11 CXX=clang++-11 make NO_UPNP_STUB=1
RUN CC=clang-11 CXX=clang++-11 make

CMD ['./AltServer']

