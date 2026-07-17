import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// SharedPreferencesAsync を使って軽量な設定値を保存する Repository 実装。
///
/// 回答や進捗のような構造化データは Drift に任せ、この実装では単純な設定だけを扱います。
class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const _speedKey = 'default_speed';
  static const _autoScrollKey = 'auto_scroll';
  static const _showChineseKey = 'show_chinese';
  static const _rememberPositionKey = 'remember_position';

  @override
  Future<AppSettings> load() async {
    return AppSettings(
      defaultSpeed: await _preferences.getDouble(_speedKey) ?? 1,
      autoScroll: await _preferences.getBool(_autoScrollKey) ?? true,
      showChinese: await _preferences.getBool(_showChineseKey) ?? true,
      rememberPosition:
          await _preferences.getBool(_rememberPositionKey) ?? true,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    // 各設定は独立しているため並列保存し、全書き込みの完了を呼び出し元へ通知します。
    await Future.wait([
      _preferences.setDouble(_speedKey, settings.defaultSpeed),
      _preferences.setBool(_autoScrollKey, settings.autoScroll),
      _preferences.setBool(_showChineseKey, settings.showChinese),
      _preferences.setBool(_rememberPositionKey, settings.rememberPosition),
    ]);
  }
}
