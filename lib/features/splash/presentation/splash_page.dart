import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';

/// Native Splashの後にブランド表示と起動待機を担当する画面。
///
/// 現時点では最低表示時間だけを管理します。将来、設定やDatabaseなどの
/// 初期化が必要になった場合は、[_completeStartup]で完了を待つ責務を拡張します。
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _minimumDisplayDuration = Duration(seconds: 1);
  static const _animationDuration = Duration(milliseconds: 700);

  late final AnimationController _animationController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _nameOpacity;
  late final Animation<double> _subtitleOpacity;

  bool _hasNavigated = false;

  @override
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

  Future<void> _completeStartup() async {
    await Future<void>.delayed(_minimumDisplayDuration);
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    // goでlocationを置換し、Back操作でSplashへ戻らないようにします。
    context.go('/practice');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
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
                              color: AppColors.accent,
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
                                  color: Colors.white,
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
                              color: AppColors.muted,
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
                          color: AppColors.muted,
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
  const _AnimatedSplashContent({
    required this.animation,
    required this.disableAnimation,
    required this.child,
    this.scaleAnimation,
  });

  final Animation<double> animation;
  final Animation<double>? scaleAnimation;
  final bool disableAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (disableAnimation) return child;
    final animatedChild = scaleAnimation == null
        ? child
        : ScaleTransition(scale: scaleAnimation!, child: child);
    return FadeTransition(opacity: animation, child: animatedChild);
  }
}
