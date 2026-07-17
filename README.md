# 聴解トレーニング

Android / iOS 向けの、オフライン優先の日语听力练习 Flutter App。MVP には練習、模擬テスト、お気に入り、学習記録、音声と本文の同期が含まれます。

## 実行

```bash
flutter pub get
dart run build_runner build
flutter run
```

品質チェック：

```bash
dart format .
flutter analyze
flutter test
```

## 教材の追加

- 教材一覧：`assets/data/catalog.json`
- 試験 JSON：`assets/data/exams/<examId>.json`
- 音声：`assets/audio/`

各文には音声ファイル内の相対時間として `startMs` と `endMs` が必要です。問題 ID、文 ID は全教材で重複させず、`correctOptionId` は必ず存在する選択肢を参照してください。不正な JSON、時間の重複、音声欠落はアプリ内のエラー状態として表示されます。

同梱の体験教材と音声はデモ用に生成したオリジナルコンテンツです。商用試験の文章や音声は同梱しないでください。
