/// 端末へ保存する再生・表示設定の immutable モデル。
class AppSettings {
  const AppSettings({
    this.defaultSpeed = 1,
    this.autoScroll = true,
    this.showChinese = true,
    this.rememberPosition = true,
  });

  final double defaultSpeed;
  final bool autoScroll;
  final bool showChinese;
  final bool rememberPosition;

  /// 指定項目だけを置き換えた新しい設定値を返します。
  AppSettings copyWith({
    double? defaultSpeed,
    bool? autoScroll,
    bool? showChinese,
    bool? rememberPosition,
  }) {
    return AppSettings(
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
      autoScroll: autoScroll ?? this.autoScroll,
      showChinese: showChinese ?? this.showChinese,
      rememberPosition: rememberPosition ?? this.rememberPosition,
    );
  }
}

/// アプリ設定の読み書きを保存方式から分離する Repository。
abstract interface class SettingsRepository {
  /// 保存値を読み込み、未保存項目には既定値を適用して返します。
  Future<AppSettings> load();

  /// 現在の設定値を端末へ保存します。
  Future<void> save(AppSettings settings);
}
