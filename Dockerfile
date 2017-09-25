FROM python:2.7-jessie

# this base image depends on buildpack-deps which already installed 
# wget, tar, gcc

ENV STAN_VERSION 2.17.0

## add a non-root user
RUN groupadd -r fit \
    && useradd --no-log-init -r -g fit fit

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
RUN pip install numpy scipy nibabel jupyter 

## expose ports
EXPOSE 8888

## add data volume
# VOLUME /data
# Using bind mounts instead

## run default script
USER fit
CMD ["jupyter", "notebook"]

