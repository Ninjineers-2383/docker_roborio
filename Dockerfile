FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install openjdk-17-jdk build-essential wget cmake net-tools -y && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# install roborio toolchain
COPY roboriotoolchain.cmake /tmp/roboriotoolchain.cmake

COPY build.gradle gradlew settings.gradle .

COPY gradle /tmp/gradle
COPY .wpilib /tmp/.wpilib

RUN ./gradlew installRoboRioToolchain \
# install zeromq linux
 && wget https://github.com/zeromq/libzmq/releases/download/v4.3.5/zeromq-4.3.5.tar.gz \
 && tar -xvf zeromq-4.3.5.tar.gz  \
 && mkdir -p zeromq-4.3.5/build \
 && cd zeromq-4.3.5/build \
 && cmake .. \
 && make \
 && make install \
 && mkdir -p /libs/linuxx86-64 \
 && cp lib/libzmq.so.5.2.5 /libs/linuxx86-64 \
 && cp /usr/local/lib/libzmq.so.5 /lib \
# install zeromq roborio
 && mkdir -p /tmp/zeromq-4.3.5/riobuild \
 && cd /tmp/zeromq-4.3.5/riobuild \
 && cmake -DCMAKE_TOOLCHAIN_FILE=/tmp/roboriotoolchain.cmake .. \
 && make CROSS_COMPILE_TARGET=yes \
 && mkdir -p /libs/linuxathena \
 && cp lib/libzmq.so.5.2.5 /libs/linuxathena \
# install protobuf
 && cd /tmp \
 && wget https://github.com/protocolbuffers/protobuf/releases/download/v27.3/protobuf-27.3.tar.gz \
 && wget https://github.com/abseil/abseil-cpp/releases/download/20240722.0/abseil-cpp-20240722.0.tar.gz \
 && tar -xvf protobuf-27.3.tar.gz \
 && tar -xvf abseil-cpp-20240722.0.tar.gz -C /tmp/protobuf-27.3/third_party/abseil-cpp/ --strip-components=1 \
 && mkdir -p /tmp/protobuf-27.3/build \
 && cd /tmp/protobuf-27.3/build \
 && cmake -Dprotobuf_BUILD_TESTS=OFF .. \
 && make \
 && make install \
 && cp libprotobuf-lite.a libprotobuf.a libprotoc.a libupb.a /libs/linuxx86-64 \
# install protobuf roborio
 && mkdir -p /tmp/protobuf-27.3/riobuild \
 && cd /tmp/protobuf-27.3/riobuild \
 && cmake -DCMAKE_TOOLCHAIN_FILE=/tmp/roboriotoolchain.cmake -Dprotobuf_BUILD_TESTS=OFF .. \
 && make CROSS_COMPILE_TARGET=yes \
 && cp libprotobuf-lite.a libprotobuf.a libprotoc.a libupb.a /libs/linuxathena \
# Clean tmp folder
 && cd / \
 && rm -rf /tmp

CMD ["/bin/bash"]