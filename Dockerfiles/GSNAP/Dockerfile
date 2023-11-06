FROM ubuntu:20.04
RUN apt-get update -qq -y --fix-missing
RUN apt-get install -y apt-utils
RUN apt-get install -y build-essential git autoconf wget lbzip2
RUN apt-get install -y zlib1g-dev libbz2-dev gsl-bin libgsl0-dev
RUN apt-get install -y libncurses5-dev liblzma-dev libssl-dev libcurl4-openssl-dev
RUN cd /usr/local/ \
    && wget http://research-pub.gene.com/gmap/src/gmap-gsnap-2020-10-27.tar.gz \
    && tar xvf gmap-gsnap-2020-10-27.tar.gz && cd gmap-2020-10-27 && ./configure && make && make install
RUN cd /usr/local/ \
    && wget http://research-pub.gene.com/gmap/src/gmap-gsnap-2019-12-01.tar.gz \
    && tar xvf gmap-gsnap-2019-12-01.tar.gz && cd gmap-2019-12-01 && ./configure --prefix=${PWD} && make && make install
RUN wget https://github.com/samtools/samtools/releases/download/1.11/samtools-1.11.tar.bz2 \
    && tar jxvf samtools-1.11.tar.bz2 && cd samtools-1.11 && ./configure && make && make install
ENTRYPOINT [] 
