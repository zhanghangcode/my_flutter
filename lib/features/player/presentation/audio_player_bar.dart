import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../application/audio_player_controller.dart';
import '../domain/question_playback_mode.dart';

/// 練習詳細の下部に固定表示する音声操作バー。
///
/// Slider と再生操作は AudioPlayerController へ委譲し、速度変更だけは次回起動時にも
/// 復元できるよう SettingsController にも保存します。SafeArea で端末下端を保護します。
class AudioPlayerBar extends ConsumerWidget {
  /// 問題の境界と切り替え中の操作可否を受け取り、固定プレイヤーを構築します。
  ///
  /// 音声の状態は Provider から監視し、問題切り替えの判断は呼び出し元の
  /// PracticeDetailController に委譲するため、この Widget は表示と操作の入口に専念します。
  const AudioPlayerBar({
    super.key,
    required this.showPreviousQuestion,
    required this.showNextQuestion,
    required this.questionNavigationEnabled,
    required this.interactionEnabled,
    required this.onPreviousQuestion,
    required this.onNextQuestion,
  });

  /// 画面下部に確保するプレイヤー本体の高さ。
  static const height = 154.0;

  /// 前の問題へ移動できるときに、左側の操作スロットを表示するかどうか。
  final bool showPreviousQuestion;

  /// 次の問題へ移動できるときに、右側の操作スロットを表示するかどうか。
  final bool showNextQuestion;

  /// 問題切り替え callback を受け付けられる状態かどうか。
  final bool questionNavigationEnabled;

  /// 音源切り替えなどの競合を避けるため、通常のプレイヤー操作を受け付けるかどうか。
  final bool interactionEnabled;

  /// 前の問題への移動を PracticeDetailPage に要求する callback。
  final VoidCallback onPreviousQuestion;

  /// 次の問題への移動を PracticeDetailPage に要求する callback。
  final VoidCallback onNextQuestion;

  /// Provider のプレイヤー状態を表示し、各操作を AudioPlayerController へ委譲します。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch は表示更新に使用し、ref.read で取得した Controller は操作時だけ呼びます。
    final player = ref.watch(audioPlayerControllerProvider);
    final controller = ref.read(audioPlayerControllerProvider.notifier);
    final maxMilliseconds = player.duration.inMilliseconds <= 0
        ? 1.0
        : player.duration.inMilliseconds.toDouble();
    final value = player.position.inMilliseconds
        .clamp(0, maxMilliseconds.toInt())
        .toDouble();
    final sourceReady =
        interactionEnabled &&
        player.hasSource &&
        player.status != AudioPlayerStatus.idle &&
        player.status != AudioPlayerStatus.loading &&
        player.status != AudioPlayerStatus.error;
    return Material(
      color: AppColors.background,
      elevation: 12,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Column(
              children: [
                if (player.status == AudioPlayerStatus.error)
                  Text(
                    player.errorMessage ?? '音声エラー',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                    ),
                  ),
                Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        _format(player.position),
                        style: const TextStyle(fontFeatures: []),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: value,
                        max: maxMilliseconds,
                        onChanged: sourceReady
                            ? (next) => controller.seek(
                                Duration(milliseconds: next.round()),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Text(
                        _format(player.duration),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PopupMenuButton<double>(
                        tooltip: '再生速度',
                        initialValue: player.speed,
                        enabled: sourceReady,
                        onSelected: (speed) async {
                          await controller.setSpeed(speed);
                          await ref
                              .read(settingsControllerProvider.notifier)
                              .saveChanges(
                                (settings) =>
                                    settings.copyWith(defaultSpeed: speed),
                              );
                        },
                        itemBuilder: (_) => [
                          for (final speed in <double>[
                            0.5,
                            0.75,
                            1,
                            1.25,
                            1.5,
                            1.75,
                            2,
                          ])
                            PopupMenuItem(
                              value: speed,
                              child: Text('${speed}x'),
                            ),
                        ],
                        child: SizedBox(
                          width: 52,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.speed),
                              Text(
                                '${player.speed}x',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: showPreviousQuestion
                            ? IconButton(
                                tooltip: '前の問題',
                                onPressed: questionNavigationEnabled
                                    ? onPreviousQuestion
                                    : null,
                                icon: const Icon(Icons.skip_previous, size: 34),
                              )
                            : null,
                      ),
                      IconButton.filled(
                        tooltip: player.isPlaying ? '一時停止' : '再生',
                        onPressed: sourceReady
                            ? controller.togglePlayPause
                            : null,
                        iconSize: 36,
                        icon:
                            interactionEnabled &&
                                player.status == AudioPlayerStatus.loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                player.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                      ),
                      SizedBox(
                        width: 48,
                        child: showNextQuestion
                            ? IconButton(
                                tooltip: '次の問題',
                                onPressed: questionNavigationEnabled
                                    ? onNextQuestion
                                    : null,
                                icon: const Icon(Icons.skip_next, size: 34),
                              )
                            : null,
                      ),
                      IconButton(
                        tooltip: _playbackModeLabel(player.playbackMode),
                        onPressed: sourceReady
                            ? controller.cycleQuestionPlaybackMode
                            : null,
                        color:
                            player.playbackMode ==
                                QuestionPlaybackMode.sequential
                            ? Colors.white
                            : AppColors.accent,
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              _playbackModeIcon(player.playbackMode),
                              size: 30,
                            ),
                            Positioned(
                              right: -7,
                              bottom: -7,
                              child: Text(
                                _playbackModeBadge(player.playbackMode),
                                style: TextStyle(
                                  color:
                                      player.playbackMode ==
                                          QuestionPlaybackMode.sequential
                                      ? Colors.white
                                      : AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Duration をプレイヤーで表示する分・秒形式へ変換します。
String _format(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// 問題再生モードに対応する Tooltip の文言を返します。
String _playbackModeLabel(QuestionPlaybackMode mode) => switch (mode) {
  QuestionPlaybackMode.repeatCurrent => '現在の問題を繰り返す',
  QuestionPlaybackMode.sequential => '問題を順番に再生',
  QuestionPlaybackMode.repeatAll => 'すべての問題を繰り返す',
};

/// 問題再生モードを区別して表示する Material icon を返します。
IconData _playbackModeIcon(QuestionPlaybackMode mode) => switch (mode) {
  QuestionPlaybackMode.repeatCurrent => Icons.repeat_one,
  QuestionPlaybackMode.sequential => Icons.playlist_play,
  QuestionPlaybackMode.repeatAll => Icons.repeat,
};

/// アイコンだけでは区別しにくい問題再生モード用の短い補助ラベルを返します。
String _playbackModeBadge(QuestionPlaybackMode mode) => switch (mode) {
  QuestionPlaybackMode.repeatCurrent => '1問',
  QuestionPlaybackMode.sequential => '順',
  QuestionPlaybackMode.repeatAll => '全',
};
