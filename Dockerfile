FROM python:2.7-jessie

# this base image depends on buildpack-deps which already installed 
# wget, tar, gcc

# this would be an alternative to the wget route
# adding stan to the image statically
# WORKDIR /opt
# ADD . /opt

ENV STAN_VERSION 2.17.0

# wget --quiet --output-document=- 
RUN wget -q -O- "https://github.com/stan-dev/cmdstan/releases/download/v$STAN_VERSION/cmdstan-$STAN_VERSION.tar.gz" \
	   | tar xvz -C /opt

# stan is confused about the compiler on this non-standard linux
RUN cd /opt/cmdstan-$STAN_VERSION \
	&& echo 'CC=g++' > make/local \
	&& make build \
	&& make clean  

