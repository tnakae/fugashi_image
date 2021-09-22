import fugashi

NEOLOGD_PATH = "/usr/local/etc/mecab-unidic-neologd"
SAMPLE_TEXT = """依頼内容に基づいて実施方針の策定をおこない、
総合的な分析・結果を踏まえた提言ができるデータサイエンティストです。"""


def run_parser(use_neologd: bool, text: str = SAMPLE_TEXT) -> None:
    if use_neologd:
        # neologd を使う場合
        # 導入済みのunidicと、neologdの両方が
        # 辞書として利用される
        parser = fugashi.Tagger(f"-d {NEOLOGD_PATH}")
    else:
        # neologd を使わない場合
        # この場合でもdefaultでは、導入済みのunidicが
        # 自動的に選択される
        parser = fugashi.Tagger()

    results = []
        
    for node in parser(text):
        pos = (node.feature.pos1, node.feature.pos2)
        if (node.feature.pos1 == "名詞" and
            node.feature.pos2 in ("普通名詞", "固有名詞") and
            node.feature.orthBase not in ['こと', 'ため', 'よう', 'うえ'] and
            node.feature.orthBase is not None):
            results.append(node.feature.orthBase)

    print("/".join(results))


def main() -> None:
    print(f"元テキスト :\n-----\n{SAMPLE_TEXT}\n-----")
    for use_neologd in [True, False]:
        neologd_str = "使う" if use_neologd else "使わない"
        print(f"neologd を{neologd_str}場合")
        run_parser(use_neologd)


if __name__ == "__main__":
    main()
