FROM ubuntu:latest
RUN apt-get update -qq -y --fix-missing
RUN apt-get install -y apt-utils
RUN apt-get install -y build-essential git autoconf wget lbzip2
RUN apt-get install -y zlib1g-dev libbz2-dev gsl-bin libgsl0-dev
RUN apt-get install -y libncurses5-dev liblzma-dev libssl-dev libcurl4-openssl-dev
RUN apt-get install -y python3 build-essential git python3-pip wget pigz
RUN pip3 install matplotlib multiprocess
RUN cd /usr/local/ \
    && git clone --recursive https://github.com/heathsc/gemBS.git \
    && cd gemBS && git switch -c v3.5.1_IHEC && python3 setup.py install
RUN cd /usr/local/ \
    && git clone https://github.com/ifishlin/WGBS_workflows.git \
    && cd WGBS_workflows/ && git checkout remotes/origin/cwl_extension && git switch -c cwl_extension \
    && cp patched/create_conf.py /usr/bin/ && cp patched/IHEC_standard_template.conf / && cp patched/run_gembs.sh /usr/bin/
ENTRYPOINT [] 
