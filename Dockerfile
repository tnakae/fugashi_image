#######################
### builder
#######################
FROM python:3.8-bullseye as builder

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    ca-certificates \
    jq \
    make \
    sudo \
    g++ \
    git \
    curl \
    file \
    patch \
    xz-utils \
    unzip \
    mecab \
    libmecab-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/neologd/mecab-unidic-neologd.git && \
    cd mecab-unidic-neologd && \
    git checkout 22895c054014393307967eddcd351c69e1fd57af && \
    cd .. && \
    ./mecab-unidic-neologd/bin/install-mecab-unidic-neologd -n -y && \
    rm -rf mecab-unidic-neologd

#######################
### runner
#######################
FROM python:3.8-slim-bullseye as runner

COPY --from=builder \
    /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-unidic-neologd \
    /usr/local/etc/mecab-unidic-neologd

COPY requirements.txt /opt/requirements.txt
COPY app /opt/app
WORKDIR /opt/app
RUN pip install -r ../requirements.txt && \
    rm -rf /root/.cache

RUN python -m unidic download

