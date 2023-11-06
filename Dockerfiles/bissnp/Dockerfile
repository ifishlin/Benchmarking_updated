FROM ubuntu:latest
RUN apt-get update 
RUN apt-get install -y openjdk-8-jdk wget 
RUN cd /usr/local/ \
    && wget https://github.com/dnaase/Bis-tools/releases/download/Bis-SNP.v1.0.1/BisSNP-1.0.1.jar 
CMD ["/bin/bash"] 
