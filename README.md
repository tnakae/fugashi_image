# fugashi_image
[fugashi](https://github.com/polm/fugashi) / [unidic](https://github.com/polm/unidic-py) / [mecab-unidic-neologd](https://github.com/neologd/mecab-unidic-neologd) を含む軽量な docker image をつくる方法の検討

## 背景
- Python 界隈では mecab ではなく fugashi を使う流れとなっている。
  - fugashi を使えば、コンパイル済みの `mecab` のバイナリが同梱されているため
    `pip install fugashi` で分かち書きを実施できる
  - 実行には辞書が必要であり、unidicの利用が推奨されている
  - unidic も同名のパッケージが用意されている。
- 一方で、`neologd` の利用が必要となる局面が多い。
  - `neologd` のビルドに `mecab` のインストールを必要とする。
  - ビルドにはコンパイラが必要であり、イメージが大きくなってしまう。

## このレポジトリの目的
- fugashi/unidic/neologd を共存させ、かつイメージがコンパクトになる
  ような Dockerfile の一案を示す。
  - Dockerfile では、マルチステージビルドを実施する。
    - 途中段階でのイメージは大きくなってしまうが、
      最終的に実行に用いるイメージは必要最小限となる。

## 利用方法
``` bash
$ docker-compose build
$ docker-compose up
```
