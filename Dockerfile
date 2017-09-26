FROM python:2.7-jessie

# this base image depends on buildpack-deps which already installed 
# wget, tar, gcc

ENV STAN_VERSION=2.17.0 \
    USR=fit

## add a non-root user
RUN groupadd $USR \
    && useradd -m -g $USR $USR

WORKDIR /opt

## get stan source
# wget --quiet --output-document=- 
RUN wget -q -O - "https://github.com/stan-dev/cmdstan/releases/download/v$STAN_VERSION/cmdstan-$STAN_VERSION.tar.gz" \
	   | tar xvz -C /opt

# this would be an alternative to the wget route
# adding stan to the image statically
# ADD . /opt


## build stan
# stan is confused about the compiler on this non-standard linux
RUN cd cmdstan-$STAN_VERSION \
	&& echo 'CC=g++' > make/local \
	&& make build \
	&& make clean  

## install python scientific libraries
RUN pip install numpy scipy nibabel 
RUN pip install matplotlib jupyter 

## expose ports
EXPOSE 8888

WORKDIR /home/$USR
## add data volume for working data and output
VOLUME data
# expecting to use read only bind mounts for input data
# chown so that the unprivileged user can write to data
RUN mkdir data \
    && chown $USR:$USR data

## run default script
USER fit
WORKDIR /home/$USR/data
# start jupyter listening on all interfaces
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]

