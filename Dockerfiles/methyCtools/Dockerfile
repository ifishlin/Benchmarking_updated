FROM centos:8.2.2004
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum install -y python2 python2-devel wget bzip2 gcc make xz-devel zlib-devel libcurl-devel ncurses-devel ncurses bzip2-devel git
RUN cd && wget https://github.com/samtools/samtools/releases/download/1.15.1/samtools-1.15.1.tar.bz2 \
    && tar -jxvf samtools-1.15.1.tar.bz2 && cd samtools-1.15.1 && ./configure && make && make install
RUN pip2 install pysam==0.7.7
RUN cd && wget https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2 && tar xjvf bwa-0.7.17.tar.bz2 && cd bwa-0.7.17 && make && ln -s /root/bwa-0.7.17/bwa /usr/bin/bwa 
RUN cd && wget https://github.com/samtools/htslib/releases/download/1.15.1/htslib-1.15.1.tar.bz2 && tar xjvf htslib-1.15.1.tar.bz2 && cd htslib-1.15.1 && ./configure && make && make install
RUN cd && git clone https://github.com/ifishlin/methylCtools && ln -s /root/methylCtools/methylCtools /usr/bin/methylCtools && chmod 755 /root/methylCtools/methylCtools
RUN cd && wget https://raw.githubusercontent.com/cimbusch/TWGBS/master/TWGBS_read_pair_reconstruction.py
#RUN cd && git clone https://github.com/hovestadt/methylCtools && ln -s /root/methylCtools/methylCtools /usr/bin/methylCtools && chmod 755 /root/methylCtools/methylCtools
RUN ln -s /usr/bin/python2 /usr/bin/python
RUN chmod 777 /root
ENTRYPOINT [] 
