FROM centos:8.2.2004
RUN yum install -y autoconf automake git python3 gcc make gcc-c++ zlib-devel
RUN git clone --depth 1 --branch 1.4.8 https://github.com/NuttyLogic/BSBolt.git && cd BSBolt && pip3 install .
ENTRYPOINT [] 
