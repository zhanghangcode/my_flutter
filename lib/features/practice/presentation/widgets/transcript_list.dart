import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../app/theme.dart';
import '../../../player/application/audio_player_controller.dart';
import '../../domain/practice_models.dart';

/// 音声位置と同期する本文一覧。
///
/// プレイヤーの活性文、お気に入り、表示設定を Riverpod から購読し、活性文が変わった
/// ときだけ自動スクロールします。footer により組み合わせ表示でも同じ同期処理を共有します。
class TranscriptList extends ConsumerStatefulWidget {
  const TranscriptList({super.key, required this.question, this.footer});

  final Question question;
  final Widget? footer;

  @override
  ConsumerState<TranscriptList> createState() => _TranscriptListState();
}

class _TranscriptListState extends ConsumerState<TranscriptList> {
  final Map<String, GlobalKey> _sentenceKeys = {};
  bool _userScrolling = false;
  String? _lastScrolledId;

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(audioPlayerControllerProvider);
    final favoriteIds = ref.watch(favoriteSentenceIdsProvider).value ?? {};
    final settings = ref.watch(settingsControllerProvider).value;
    final timelineAvailable = widget.question.hasCompleteTimeline;
    final synchronizationEnabled =
        timelineAvailable &&
        player.questionId == widget.question.id &&
        player.status != AudioPlayerStatus.idle &&
        player.status != AudioPlayerStatus.loading &&
        player.status != AudioPlayerStatus.error;
    final activeId =
        timelineAvailable && player.questionId == widget.question.id
        ? player.activeSentenceId
        : null;

    // ユーザーの手動スクロールを妨げず、活性文 ID が変化した場合だけ追従します。
    if (activeId != null &&
        activeId != _lastScrolledId &&
        !_userScrolling &&
        (settings?.autoScroll ?? true)) {
      _lastScrolledId = activeId;
      // 対象行の BuildContext は描画後に確定するため、次の frame で移動します。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final keyContext = _sentenceKeys[activeId]?.currentContext;
        if (keyContext != null && mounted) {
          Scrollable.ensureVisible(
            keyContext,
            duration: const Duration(milliseconds: 280),
            alignment: 0.35,
            curve: Curves.easeOut,
          );
        }
      });
    }

    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        // スクロール操作中は自動移動を止め、操作終了後から再開します。
        _userScrolling = notification.direction != ScrollDirection.idle;
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount:
            widget.question.sentences.length + (widget.footer == null ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == widget.question.sentences.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: widget.footer!,
            );
          }
          final sentence = widget.question.sentences[index];
          final key = _sentenceKeys.putIfAbsent(sentence.id, GlobalKey.new);
          return TranscriptSentenceTile(
            key: key,
            questionId: widget.question.id,
            sentence: sentence,
            active: sentence.id == activeId,
            seekEnabled: synchronizationEnabled,
            favorite: favoriteIds.contains(sentence.id),
            showChinese: settings?.showChinese ?? true,
          );
        },
      ),
    );
  }
}

/// 1 文の本文、翻訳、同期状態、お気に入り操作を表示する Widget。
///
/// 行タップは AudioPlayerController へ seek を依頼し、星アイコンは
/// LearningRepository へ保存を依頼するため、Widget は各 Plugin を直接扱いません。
class TranscriptSentenceTile extends ConsumerWidget {
  const TranscriptSentenceTile({
    super.key,
    required this.questionId,
    required this.sentence,
    required this.active,
    required this.seekEnabled,
    required this.favorite,
    required this.showChinese,
  });

  final String questionId;
  final TranscriptSentence sentence;
  final bool active;
  final bool seekEnabled;
  final bool favorite;
  final bool showChinese;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSentenceTime = sentence.startMs != null && sentence.endMs != null;
    return Semantics(
      button: seekEnabled,
      enabled: seekEnabled,
      hint: seekEnabled
          ? 'この文の開始位置へ移動します'
          : hasSentenceTime
          ? '音声を準備しています'
          : 'この文には時間情報がありません',
      child: InkWell(
        onTap: seekEnabled
            ? () => ref
                  .read(audioPlayerControllerProvider.notifier)
                  .seekToSentence(sentence)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.fromLTRB(12, 14, 4, 14),
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                width: 4,
                color: active ? AppColors.accent : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${sentence.speaker == null ? '' : '${sentence.speaker}：'}${sentence.textJa}',
                      style: TextStyle(
                        color: active ? AppColors.accent : Colors.white,
                        fontSize: 18,
                        height: 1.55,
                      ),
                    ),
                    if (showChinese && sentence.translationZh != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        sentence.translationZh!,
                        style: const TextStyle(
                          color: Colors.white54,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: favorite ? '文のお気に入りを解除' : '文をお気に入りに追加',
                onPressed: () => ref
                    .read(learningRepositoryProvider)
                    .toggleSentenceFavorite(sentence.id, questionId),
                icon: Icon(
                  favorite ? Icons.star : Icons.star_outline,
                  color: favorite ? Colors.amber : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
