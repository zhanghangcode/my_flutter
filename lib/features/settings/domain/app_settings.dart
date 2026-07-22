import 'package:flutter/material.dart' show ThemeMode;

/// 端末へ保存する再生・表示設定の immutable モデル。
class AppSettings {
  /// 端末へ保存する再生・表示設定を生成します。
  ///
  /// [defaultSpeed]は既定の再生倍率、各boolは表示・復元機能の既定状態です。
  /// [themeMode]は既存ユーザーの見た目を変えないよう既定で[ThemeMode.dark]とします。
  /// すべて任意で、省略時は学習に適した標準値を使用します。生成時に永続化は行いません。
  const AppSettings({
    this.defaultSpeed = 1,
    this.autoScroll = true,
    this.showChinese = true,
    this.rememberPosition = true,
    this.themeMode = ThemeMode.dark,
  });

  /// 新しい問題を読み込む時に適用する再生速度の倍率です。
  final double defaultSpeed;

  /// 活性文の変更に合わせてTranscriptを自動スクロールするかを示します。
  final bool autoScroll;

  /// 中国語訳と中国語解説を表示するかを示します。
  final bool showChinese;

  /// 問題ごとの最後の再生位置を次回復元するかを示します。
  final bool rememberPosition;

  /// ライト/ダーク/端末設定追従のうち、利用者が選択した表示テーマです。
  final ThemeMode themeMode;

  /// 指定項目だけを置き換えた新しい設定値を返します。
  ///
  /// 各任意引数が`null`の場合は現在の値を維持します。元のinstanceは変更しません。
  AppSettings copyWith({
    double? defaultSpeed,
    bool? autoScroll,
    bool? showChinese,
    bool? rememberPosition,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      autoScroll: autoScroll ?? this.autoScroll,
      showChinese: showChinese ?? this.showChinese,
      rememberPosition: rememberPosition ?? this.rememberPosition,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// アプリ設定の読み書きを保存方式から分離する Repository。
abstract interface class SettingsRepository {
  /// 保存値を読み込み、未保存項目には既定値を適用して返します。
  Future<AppSettings> load();

  /// 現在の設定値を端末へ保存します。
  ///
  /// [settings]は保存対象のimmutable設定値です。
  Future<void> save(AppSettings settings);
}
