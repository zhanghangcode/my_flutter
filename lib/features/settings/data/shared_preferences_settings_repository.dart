import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

/// SharedPreferencesAsync を使って軽量な設定値を保存する Repository 実装。
///
/// 回答や進捗のような構造化データは Drift に任せ、この実装では単純な設定だけを扱います。
class SharedPreferencesSettingsRepository implements SettingsRepository {
  /// SharedPreferencesを使用する設定Repositoryを生成します。
  ///
  /// [preferences]を指定するとテスト用のSharedPreferencesAsyncを注入できます。`null`の場合は
  /// 新しいSharedPreferencesAsyncを生成します。生成時にI/Oは行いません。
  SharedPreferencesSettingsRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  /// 設定値を非同期で読み書きするSharedPreferences APIです。
  final SharedPreferencesAsync _preferences;

  /// 既定再生速度を保存するKeyです。
  static const _speedKey = 'default_speed';

  /// 自動スクロール設定を保存するKeyです。
  static const _autoScrollKey = 'auto_scroll';

  /// 中国語表示設定を保存するKeyです。
  static const _showChineseKey = 'show_chinese';

  /// 再生位置復元設定を保存するKeyです。
  static const _rememberPositionKey = 'remember_position';

  /// 表示テーマ設定を保存するKeyです。
  static const _themeModeKey = 'theme_mode';

  @override
  /// SharedPreferencesから設定を非同期で読み込みます。
  ///
  /// 保存値がないKeyには[AppSettings]と同じ既定値を適用します。
  Future<AppSettings> load() async {
    return AppSettings(
      defaultSpeed: await _preferences.getDouble(_speedKey) ?? 1,
      autoScroll: await _preferences.getBool(_autoScrollKey) ?? true,
      showChinese: await _preferences.getBool(_showChineseKey) ?? true,
      rememberPosition:
          await _preferences.getBool(_rememberPositionKey) ?? true,
      themeMode: _parseThemeMode(await _preferences.getString(_themeModeKey)),
    );
  }

  @override
  /// すべての設定値をSharedPreferencesへ非同期で保存します。
  ///
  /// [settings]の各項目は独立したKeyへ並列に書き込まれます。
  Future<void> save(AppSettings settings) async {
    // 各設定は独立しているため並列保存し、全書き込みの完了を呼び出し元へ通知します。
    await Future.wait([
      _preferences.setDouble(_speedKey, settings.defaultSpeed),
      _preferences.setBool(_autoScrollKey, settings.autoScroll),
      _preferences.setBool(_showChineseKey, settings.showChinese),
      _preferences.setBool(_rememberPositionKey, settings.rememberPosition),
      _preferences.setString(_themeModeKey, settings.themeMode.name),
    ]);
  }

  /// 保存済み文字列を[ThemeMode]へ復元します。未保存または不正値は既存ユーザーの
  /// 見た目を変えないよう[ThemeMode.dark]にフォールバックします。
  ThemeMode _parseThemeMode(String? value) {
    if (value == null) return ThemeMode.dark;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.dark,
    );
  }
}
