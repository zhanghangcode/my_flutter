/// 練習詳細で使用する問題単位の連続再生モード。
enum QuestionPlaybackMode {
  /// 現在の問題だけを繰り返します。
  repeatCurrent,

  /// 試験内の問題を順番に再生し、末尾で停止します。
  sequential,

  /// 試験内の問題を順番に再生し、末尾から先頭へ戻ります。
  repeatAll,
}
