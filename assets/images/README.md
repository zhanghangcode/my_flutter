# 問題図版（画像タイプの問題）

`Question.imageAssetPath`が非`null`の問題は、問題文と一緒に図版（地図・グラフなど）を
表示します。bundled教材はこのディレクトリに直接ファイルを置き、教材JSONで
`assets/images/<ファイル名>`のように参照してください。

```json
{
  "id": "n2_q01",
  "imageAssetPath": "assets/images/n2_q01.jpg"
}
```

downloadRequired教材（R2 ZIP配布）では、画像もZIP内に含めることで音声と同じ
ダウンロード・検証フローの対象になります。詳細は`docs/r2_audio_packages.md`を
参照してください。
