FROM centos:8.2.2004
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum install -y python3 python3-devel wget bzip2 gcc make xz-devel zlib-devel libcurl-devel ncurses-devel ncurses bzip2-devel git
RUN cd && wget https://github.com/samtools/samtools/releases/download/1.15.1/samtools-1.15.1.tar.bz2 \
    && tar -jxvf samtools-1.15.1.tar.bz2 && cd samtools-1.15.1 && ./configure && make && make install
RUN cd && wget https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2 && tar xjvf bwa-0.7.17.tar.bz2 \ 
    && cd bwa-0.7.17 && make && ln -s /root/bwa-0.7.17/bwa /usr/bin/bwa
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN pip3 install toolshed 
RUN cd && git clone https://github.com/dpryan79/bwa-meth bwa-meth_pbat && cd bwa-meth_pbat && git checkout remotes/origin/pbat \
    && mv bwameth.py bwameth_pbat.py
RUN ln -s /root/bwa-meth_pbat/bwameth_pbat.py /usr/bin/bwameth_pbat.py
RUN cd && git clone https://github.com/dpryan79/bwa-meth 
RUN ln -s /root/bwa-meth/bwameth.py /usr/bin/bwameth.py
RUN chmod -R 777 /root
ENTRYPOINT [] 
