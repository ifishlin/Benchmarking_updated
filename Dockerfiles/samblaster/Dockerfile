FROM centos:8.2.2004
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum install -y wget gcc gcc-c++ make git zlib-devel bzip2 bzip2-devel xz-devel unzip libcurl-devel ncurses-devel ncurses
RUN cd && git clone https://github.com/GregoryFaust/samblaster && cd samblaster && make && cp samblaster /usr/bin
RUN cd && wget https://github.com/samtools/samtools/releases/download/1.15.1/samtools-1.15.1.tar.bz2 \
    && tar -jxvf samtools-1.15.1.tar.bz2 && cd samtools-1.15.1 && ./configure && make && make install
ENTRYPOINT [] 
