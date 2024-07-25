FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install openjdk-17-jdk build-essential wget cmake -y && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# install roborio toolchain

COPY build.gradle gradlew settings.gradle .

COPY gradle /tmp/gradle
COPY .wpilib /tmp/.wpilib

RUN ./gradlew installRoboRioToolchain

RUN wget https://github.com/zeromq/libzmq/releases/download/v4.3.5/zeromq-4.3.5.tar.gz \
 && tar -xvf zeromq-4.3.5.tar.gz  \
 && mkdir -p zeromq-4.3.5/build \
 && cd zeromq-4.3.5/build \
 && cmake .. \
 && make \
 && make install \
 && mkdir -p /libs/linuxx86-64 \
 && cp lib/libzmq.so.5.2.5 /libs/linuxx86-64 \
 && cp /usr/local/lib/libzmq.so.5 /lib

COPY roboriotoolchain.cmake /tmp/roboriotoolchain.cmake

RUN mkdir -p /tmp/zeromq-4.3.5/riobuild \
 && cd /tmp/zeromq-4.3.5/riobuild \
 && cmake .. -DCMAKE_TOOLCHAIN_FILE=/tmp/roboriotoolchain.cmake \
 && make CROSS_COMPILE_TARGET=yes \
 && mkdir -p /libs/linuxathena \
 && cp lib/libzmq.so.5.2.5 /libs/linuxathena

# install zeromq 