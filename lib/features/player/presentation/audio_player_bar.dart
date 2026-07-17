import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../practice/domain/practice_models.dart';
import '../application/audio_player_controller.dart';

class AudioPlayerBar extends ConsumerWidget {
  const AudioPlayerBar({super.key});

  static const height = 154.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(audioPlayerControllerProvider);
    final controller = ref.read(audioPlayerControllerProvider.notifier);
    final maxMilliseconds = player.duration.inMilliseconds <= 0
        ? 1.0
        : player.duration.inMilliseconds.toDouble();
    final value = player.position.inMilliseconds
        .clamp(0, maxMilliseconds.toInt())
        .toDouble();
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
                        onChanged: player.hasSource
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
                      IconButton(
                        tooltip: '前の文',
                        onPressed: player.hasSource
                            ? controller.previousSentence
                            : null,
                        icon: const Icon(Icons.skip_previous, size: 34),
                      ),
                      IconButton.filled(
                        tooltip: player.isPlaying ? '一時停止' : '再生',
                        onPressed: player.hasSource
                            ? controller.togglePlayPause
                            : null,
                        iconSize: 36,
                        icon: player.status == AudioPlayerStatus.loading
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
                      IconButton(
                        tooltip: '次の文',
                        onPressed: player.hasSource
                            ? controller.nextSentence
                            : null,
                        icon: const Icon(Icons.skip_next, size: 34),
                      ),
                      IconButton(
                        tooltip: _repeatLabel(player.repeatMode),
                        onPressed: player.hasSource
                            ? controller.cycleRepeatMode
                            : null,
                        color: player.repeatMode == RepeatMode.none
                            ? Colors.white
                            : AppColors.accent,
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.repeat, size: 30),
                            if (player.repeatMode != RepeatMode.none)
                              Positioned(
                                right: -5,
                                bottom: -6,
                                child: Text(
                                  player.repeatMode == RepeatMode.sentence
                                      ? '文'
                                      : '問',
                                  style: const TextStyle(
                                    color: AppColors.accent,
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

String _format(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _repeatLabel(RepeatMode mode) => switch (mode) {
  RepeatMode.none => 'リピートなし',
  RepeatMode.sentence => '現在の文をリピート',
  RepeatMode.question => '現在の問題をリピート',
};
