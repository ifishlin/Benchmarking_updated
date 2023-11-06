FROM christianbioinf/bat
RUN apt-get update -qq -y --fix-missing
RUN apt-get install -y libbz2-dev libncurses5-dev libcurl4-openssl-dev
RUN cd && wget https://github.com/samtools/htslib/releases/download/1.11/htslib-1.11.tar.bz2 \
    && tar jxvf htslib-1.11.tar.bz2 && cd htslib-1.11 && ./configure && make && make install
RUN cd && wget https://github.com/samtools/bcftools/releases/download/1.15.1/bcftools-1.15.1.tar.bz2 \
    && tar jxvf bcftools-1.15.1.tar.bz2 && cd bcftools-1.15.1 && ./configure && make && make install
RUN wget https://www.bioinf.uni-leipzig.de/Software/segemehl/downloads/segemehl-0.3.4.tar.gz \
    && tar zxvf segemehl-0.3.4.tar.gz && cd segemehl-0.3.4 && make all
RUN cd segemehl-0.3.4 && cp segemehl.x /usr/local/bin/ && cp haarz.x /usr/local/bin/
RUN cd /usr/local/bin && rm BAT_merging \
    && wget https://raw.githubusercontent.com/ifishlin/Benchmarking_CWL/main/workflows/BAT/patch/header_chr \
    && wget https://raw.githubusercontent.com/ifishlin/Benchmarking_CWL/main/workflows/BAT/patch/BAT_mapping_updated \
    && wget https://raw.githubusercontent.com/ifishlin/Benchmarking_CWL/main/workflows/BAT/patch/BAT_merging_updated \
    && mv BAT_mapping_updated BAT_mapping && mv BAT_merging_updated BAT_merging && chmod 755 BAT_mapping BAT_merging
ENTRYPOINT []
