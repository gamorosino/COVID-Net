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
                     vim \
		     python3-pip

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
  && git checkout f1d57e1eab9fe75d9a657040d949c22b68346cea  
#docker

## Download Checkpoints

RUN  cd / \
	&& /bin/bash -c 'source /COVID-Net/gdrive_download.sh;\
	mkdir -p "/COVID-Net/models/";\
	mkdir -p "/COVID-Net/models/COVIDNet-CXR3-B/";\
	gdrive_download "https://drive.google.com/file/d/13FM9OV_jecYGU4TRZqi-ARMxiSzFedE6/view?usp=sharing"  "/COVID-Net/models/COVIDNet-CXR3-B/model-1545.data-00000-of-00001" ; \ 
	gdrive_download "https://drive.google.com/file/d/1NaclbqBr3Y9XsDD8wKSy7XBEv4PtSsGb/view?usp=sharing"  "/COVID-Net/models/COVIDNet-CXR3-B/model-1545.index" ; \ 
	gdrive_download "https://drive.google.com/file/d/1uYcH6SCNkmD8SSBSP3x4LNnbC8k_5MfW/view?usp=sharing"  "/COVID-Net/models/COVIDNet-CXR3-B/model.meta" ; \ 
	gdrive_download "https://drive.google.com/file/d/113THwXyG8WH5aQfId1na7NARGn5m8qDG/view?usp=sharing"  "/COVID-Net/models/COVIDNet-CXR3-B/checkpoint" ; \ 
	mkdir "/data"; \
	gdrive_download "https://drive.google.com/file/d/1S2DCDac9g1FoUBjQgo-_8TZoI3lQX0Cp/view?usp=sharing" "/data/PROVA.jpg" ;'

# to cite COVID-Net
#@misc{wang2020covidnet,
#    title={COVID-Net: A Tailored Deep Convolutional Neural Network Design for Detection of COVID-19 Cases from Chest Radiography Images},
#    author={Linda Wang, Zhong Qiu Lin and Alexander Wong},
#    year={2020},
#    eprint={2003.09871},
#    archivePrefix={arXiv},
#    primaryClass={cs.CV}
#}

## Create virtual env

#--user
RUN cd / \
	&& python3 -m pip install  virtualenv \
	&& python3 -m venv env \
	&& source env/bin/activate \
	&& pip install tensorflow-io \
	&& pip install tensorflow==2.2.0 \
	&& deactivate

 

#make it work under singularity 
#https://wiki.ubuntu.com/DashAsBinSh 
RUN ldconfig

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
