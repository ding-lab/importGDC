FROM ubuntu:latest

LABEL author="Matt Wyczalkowski" \
      maintainer="m.wyczalkowski@wustl.edu"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    jq \
    libnss-sss \
    samtools \
    vim-tiny \
    wget \
    zip \
    && apt-get clean

RUN cd /usr/local \
    && wget https://gdc.cancer.gov/files/public/file/gdc-client_v1.6.1_Ubuntu_x64.zip \
    && unzip gdc-client_v1.6.1_Ubuntu_x64.zip \
    && mv gdc-client /usr/local/bin

COPY . /usr/local/importGDC
WORKDIR /usr/local/importGDC

CMD ["/bin/bash"]
