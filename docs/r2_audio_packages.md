# R2 音声ZIPの配置規約

Appは、ダウンロード必須教材（`audioDeliveryMode: "downloadRequired"`）の音声ZIPを、
`assets/data/catalog.json`の各教材エントリに設定した`audioPackageUrl`から直接取得します。
命名規約からURLを自動生成することはせず、教材ごとに完全なHTTPS URLを指定してください。

```json
{
  "id": "n2_listening",
  "year": 2024,
  "month": 7,
  "titleJa": "2024年7月・JLPT N2聴解",
  "audioQuality": "不明",
  "questionCount": 29,
  "resourcePath": "assets/data/exams/n2_listening_problem123.json",
  "supportsTest": false,
  "audioDeliveryMode": "downloadRequired",
  "audioResourceVersion": 1,
  "audioPackageUrl": "https://download.appsaudio.com/202407_audio.zip"
}
```

`audioPackageUrl`は`https`スキームかつhostを含む完全なURLである必要があります。それ以外
（`http`、空、不正な形式、bundled教材での未設定）は音声パッケージURLの設定エラーとして
扱われ、ダウンロードは失敗します。

`audioResourceVersion`はURLの一部ではなく、端末に保存済みの音声が最新かを判定するための
Local Manifestキャッシュ無効化専用の番号です。ZIPの中身を更新する場合は、URLを変更するか
（別のObject Keyへ配置するなど）、`audioResourceVersion`を増やして端末側の再ダウンロードを
促してください。旧Appが参照していたURLは、すぐに削除しないでください。

## ZIPの内容

ZIPには教材JSONの`audioAssetPath`と同じファイル名（basename）を、それぞれ1つだけ含めます。
展開後のファイルはbasenameの一致で照合するため、次のような構成を利用できます。

- サブディレクトリを含めてよい（例: `audio-vbr/`配下にすべての音声を配置）。ZIPのルート
  直下である必要はなく、任意の深さのディレクトリから再帰的に探索します。
- 日本語などのUTF-8ファイル名をそのまま使用できます。
- macOSの`zip`やFinderの圧縮機能が生成する`__MACOSX/`ディレクトリや`._<name>`形式の
  AppleDouble ファイルは、basenameが一致しないため自動的に無視されます。追加の除外設定は
  不要です。
- 同じbasenameを持つファイルを複数含めないでください（重複はダウンロード失敗として扱われ、
  全体がロールバックされます）。
- 絶対パス、`..`を含む相対パス、シンボリックリンクを含むZIPはすべて拒否されます。

```text
audio-vbr/問題1_第01問.mp3
audio-vbr/問題1_第02問.mp3
...
audio-vbr/問題5_第02問.mp3
```

macOSでZIPを作成する例です（`audio-vbr/`配下にまとめる場合）。

```bash
zip -r 202407_audio.zip audio-vbr
```

ルート直下にまとめる体験版ZIPの例です。

```bash
zip -j 2026_07_demo-v1.zip \
  assets/audio/demo_q1.wav \
  assets/audio/demo_q2.wav \
  assets/audio/demo_q3.wav
```

## 画像タイプの問題（imageAssetPath）

教材JSONの`Question.imageAssetPath`が非`null`の問題は、同じZIPに画像も含めてください。
音声と同様にbasenameの一致で照合し、`imageAssetPath`を持つ問題の分だけが対象になります
（画像を持たない問題は無視されます）。音声・画像は同じZIP・同じ`audioPackageUrl`から
まとめて取得し、端末では`downloads/exams/<examId>/audio/`と`.../images/`へ別々に保存
されます。

```text
audio-vbr/問題1_第01問.mp3
images/問題1_第01問.jpg
```

## ダウンロード前の検証について

`downloadRequired`教材はBundle Assetを同梱しないため、教材読み込み時（`getExam`）では
問題データ（本文・選択肢・時間軸など）だけを検証し、音声・画像ファイルの存在確認は行い
ません。実在・非0-byte・件数一致の検証は、ZIPダウンロード後にLocal Directoryへ対して
行います。
