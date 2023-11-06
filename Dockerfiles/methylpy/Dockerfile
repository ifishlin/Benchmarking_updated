FROM centos:8.2.2004
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum install -y wget gcc make git zlib-devel bzip2 bzip2-devel xz-devel unzip libcurl-devel ncurses-devel ncurses
RUN yum install -y python38 python38-devel java-1.8.0-openjdk-devel  
RUN pip3 install numpy scipy
#RUN pip3 install numpy
RUN cd && wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.5/bowtie2-2.4.5-linux-x86_64.zip && unzip bowtie2-2.4.5-linux-x86_64.zip
RUN cd && wget https://github.com/samtools/samtools/releases/download/1.15.1/samtools-1.15.1.tar.bz2 \
    && tar -jxvf samtools-1.15.1.tar.bz2 && cd samtools-1.15.1 && ./configure && make && make install
RUN cd && wget https://github.com/broadinstitute/picard/releases/download/2.27.1/picard.jar 
RUN cd /usr/bin && wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64.v385/bigWigToWig && chmod 777 bigWigToWig
#RUN cd && python3 -m pip install --user --upgrade cutadapt==1.9.1
RUN cd && python3 -m pip install cutadapt==2.7 && ln -s /root/.local/bin/cutadapt /usr/bin/cutadapt
RUN ln -s /root/bowtie2-2.4.5-linux-x86_64/bowtie2 /usr/bin/bowtie2
RUN ln -s /root/bowtie2-2.4.5-linux-x86_64/bowtie2-build /usr/bin/bowtie2-build
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN chmod 755 -R /root
RUN cd && git clone https://github.com/yupenghe/methylpy.git && cd methylpy && python setup.py install && ln -s /root/methylpy/bin/methylpy /usr/bin/methylpy
ENTRYPOINT [] 
