FROM centos:8.2.2004
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum install -y git make bzip2 xz-devel zlib-devel gcc-c++
RUN cd && git clone https://github.com/FischerJo/FAME && cd FAME && sed -i 's/READLEN = 100/READLEN = 150/g' CONST.h && make
RUN ln -s /root/FAME/FAME /usr/bin/FAME
RUN chmod 755 /root
ENTRYPOINT [] 
