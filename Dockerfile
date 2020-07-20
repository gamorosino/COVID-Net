FROM ubuntu:bionic-20200630 


MAINTAINER Gabriele

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install \
                    -y --no-install-recommends \
                     software-properties-common \
                     build-essential \
                     apt-transport-https \
                     ca-certificates \
                     gnupg \
                     software-properties-common \
                     wget \
                     ninja-build \
                      git \
                      zlib1g-dev \
                     apt-utils \
                     g++ \
                     libeigen3-dev \
                     libqt4-opengl-dev libgl1-mesa-dev libfftw3-dev libtiff5-dev \
                     jq \
                     strace \
                     curl \
                     vim 

## install Conda
ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda2-py27_4.8.3-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

## install Python Modules with Conda

RUN  conda install -c anaconda python=3.6 scikit-learn numpy  \
      && conda install -c conda-forge opencv matplotlib \
      && conda install -c anaconda tensorflow-gpu=1.15.0 


## Clone COVID-Net

RUN cd / \
  && git clone https://github.com/gamorosino/COVID-Net.git \
  && cd COVID-Net \
  && git checkout docker


# to cite COVID-Net
#@misc{wang2020covidnet,
#    title={COVID-Net: A Tailored Deep Convolutional Neural Network Design for Detection of COVID-19 Cases from Chest Radiography Images},
#    author={Linda Wang, Zhong Qiu Lin and Alexander Wong},
#    year={2020},
#    eprint={2003.09871},
#    archivePrefix={arXiv},
#    primaryClass={cs.CV}
#}
 

#make it work under singularity 
#https://wiki.ubuntu.com/DashAsBinSh 
RUN ldconfig

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
