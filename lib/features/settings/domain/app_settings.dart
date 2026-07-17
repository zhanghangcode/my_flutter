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

abstract interface class SettingsRepository {
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);
}
