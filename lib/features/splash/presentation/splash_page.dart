import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';

/// Native Splashの後にブランド表示と起動待機を担当する画面。
///
/// 現時点では最低表示時間だけを管理します。将来、設定やDatabaseなどの
/// 初期化が必要になった場合は、[_completeStartup]で完了を待つ責務を拡張します。
class SplashPage extends StatefulWidget {
  /// Native Splash後のFlutter Splash画面を生成します。
  ///
  /// [key]は任意のWidget識別子です。起動待機とRoute遷移はStateの[initState]で開始します。
  const SplashPage({super.key});

  @override
  /// Animationと起動待機を管理するStateを生成します。
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// Flutter Splashを最低限表示する時間です。
  static const _minimumDisplayDuration = Duration(seconds: 1);

  /// ロゴと文言の表示Animationに使う時間です。
  static const _animationDuration = Duration(milliseconds: 700);

  /// ロゴ・文言Animationを進行させるControllerです。
  late final AnimationController _animationController;

  /// ロゴのフェードイン値です。
  late final Animation<double> _logoOpacity;

  /// ロゴの拡大率です。
  late final Animation<double> _logoScale;

  /// アプリ名のフェードイン値です。
  late final Animation<double> _nameOpacity;

  /// サブタイトルのフェードイン値です。
  late final Animation<double> _subtitleOpacity;

  /// `/practice`への遷移を一度だけ実行したかを示します。
  bool _hasNavigated = false;

  @override
  /// Animationを準備し、起動完了待機を一度だけ開始します。
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _logoOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.96, end: 1).animate(_logoOpacity);
    _nameOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );
    _subtitleOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1, curve: Curves.easeOut),
    );

    _animationController.forward();
    // 起動処理はinitStateから一度だけ開始し、rebuildによる多重遷移を防ぎます。
    unawaited(_completeStartup());
  }

  /// 最低表示時間の経過後に練習画面へ履歴を残さず遷移します。
  ///
  /// dispose済み、または既に遷移済みの場合はBuildContextを使用せず終了します。
  Future<void> _completeStartup() async {
    await Future<void>.delayed(_minimumDisplayDuration);
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    // goでlocationを置換し、Back操作でSplashへ戻らないようにします。
    context.go('/practice');
  }

  @override
  /// AnimationControllerを破棄してTickerを解放します。
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  /// ロゴ、アプリ名、起動インジケーターを含むSplash UIを構築します。
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 420;
              final logoSize = compact ? 76.0 : 96.0;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AnimatedSplashContent(
                          animation: _logoOpacity,
                          scaleAnimation: _logoScale,
                          disableAnimation: disableAnimations,
                          child: Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.headphones,
                              size: compact ? 38 : 48,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 18 : 24),
                        _AnimatedSplashContent(
                          animation: _nameOpacity,
                          disableAnimation: disableAnimations,
                          child: Text(
                            '聴解トレーニング',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _AnimatedSplashContent(
                          animation: _subtitleOpacity,
                          disableAnimation: disableAnimations,
                          child: const Text(
                            '聴いて、読んで、身につける',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Semantics(
                      label: '読み込み中',
                      child: const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedSplashContent extends StatelessWidget {
  /// Animationの有効状態に応じて子Widgetをフェード・拡大表示するWidgetを生成します。
  ///
  /// [animation]はフェード値、[scaleAnimation]は任意の拡大率です。`null`の場合は拡大せず、
  /// [disableAnimation]が`true`なら[child]を静止表示します。
  const _AnimatedSplashContent({
    required this.animation,
    required this.disableAnimation,
    required this.child,
    this.scaleAnimation,
  });

  /// フェード表示に使用する0から1のAnimationです。
  final Animation<double> animation;

  /// 任意の拡大率Animationです。`null`ならScaleTransitionを使用しません。
  final Animation<double>? scaleAnimation;

  /// OSのreduce motion設定によりAnimationを省略するかを示します。
  final bool disableAnimation;

  /// Animation対象となる子Widgetです。
  final Widget child;

  @override
  /// 設定に応じて静止WidgetまたはFadeTransition・ScaleTransitionを構築します。
  Widget build(BuildContext context) {
    if (disableAnimation) return child;
    final animatedChild = scaleAnimation == null
        ? child
        : ScaleTransition(scale: scaleAnimation!, child: child);
    return FadeTransition(opacity: animation, child: animatedChild);
  }
}
