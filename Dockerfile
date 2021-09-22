##########################################################
### builder : neologd の辞書構築のためだけに用いるイメージ
##########################################################

# builder には slim ではない debian を使う
# ビルドに必要な gcc / cmake などが含まれている
# 現時点で最新の debian である bullseye を利用
FROM python:3.8-bullseye as builder

# mecab-unidic-neologd のビルドに必要なパッケージをインストール
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends mecab libmecab-dev sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# mecab-unidic-neologd のビルドに必要なパッケージをインストール
# 辞書は /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-unidic-neologd に格納される
WORKDIR /opt
RUN git clone https://github.com/neologd/mecab-unidic-neologd.git && \
    cd mecab-unidic-neologd && \
    git checkout 22895c054014393307967eddcd351c69e1fd57af && \
    cd .. && \
    ./mecab-unidic-neologd/bin/install-mecab-unidic-neologd -n -y && \
    rm -rf mecab-unidic-neologd

##########################################################
### runner : 実行のために用いるイメージ
##########################################################

# runner には、実行に必要最小限の slim のイメージを用いる
# 現時点で最新の debian である bullseye を利用
FROM python:3.8-slim-bullseye as runner

# builderからneologd辞書をコピーする。
# コピー先は任意だが、ここでは /usr/local/etc にコピーすることとした
COPY --from=builder \
    /usr/lib/x86_64-linux-gnu/mecab/dic/mecab-unidic-neologd \
    /usr/local/etc/mecab-unidic-neologd

# 必要あればここで apt-get によるインストールを実施
# RUN apt-get -y update && \
#     apt-get install -y --no-install-recommends jq && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app

# pythonパッケージのインストール
COPY requirements.txt /opt/requirements.txt
RUN pip install -r ../requirements.txt && \
    rm -rf /root/.cache

# unidic のダウンロード (default では AWS から取得)
RUN python -m unidic download

# 実行ファイルのコピー
COPY app /opt/app

CMD python ./sample.py
