import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../extensions/build_context_x.dart';
import '../theme/app_theme.dart';
import 'app_modal.dart';
import 'app_panel.dart';

class AppLoadingOverlay extends StatefulWidget {
  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.delay = const Duration(milliseconds: 180),
    this.useBlur = false,
  });

  final Widget child;
  final bool isLoading;
  final String? message;
  final Duration delay;
  final bool useBlur;

  @override
  State<AppLoadingOverlay> createState() => _AppLoadingOverlayState();
}

class _AppLoadingOverlayState extends State<AppLoadingOverlay> {
  Timer? _showTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _syncVisibility();
  }

  @override
  void didUpdateWidget(covariant AppLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading ||
        oldWidget.delay != widget.delay) {
      _syncVisibility();
    }
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;
    final barrierColor = resolveAppModalBarrierColor(
      brightness,
    ).withValues(alpha: brightness == Brightness.dark ? 0.28 : 0.18);

    return Stack(
      fit: StackFit.expand,
      children: [
        AbsorbPointer(absorbing: widget.isLoading, child: widget.child),
        IgnorePointer(
          ignoring: !_isVisible,
          child: AnimatedOpacity(
            opacity: _isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: DecoratedBox(
              decoration: BoxDecoration(color: barrierColor),
              child: widget.useBlur
                  ? _BlurredOverlayContent(
                      message: widget.message,
                      tokens: tokens,
                    )
                  : _OverlayContent(message: widget.message, tokens: tokens),
            ),
          ),
        ),
      ],
    );
  }

  void _syncVisibility() {
    _showTimer?.cancel();

    if (!widget.isLoading) {
      if (_isVisible) {
        setState(() {
          _isVisible = false;
        });
      }
      return;
    }

    _showTimer = Timer(widget.delay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isVisible = true;
      });
    });
  }
}

class _BlurredOverlayContent extends StatelessWidget {
  const _BlurredOverlayContent({required this.message, required this.tokens});

  final String? message;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: _OverlayContent(message: message, tokens: tokens),
    );
  }
}

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({required this.message, required this.tokens});

  final String? message;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: message == null || message!.isEmpty
          ? const _LoadingLottie()
          : ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Padding(
                padding: EdgeInsets.all(tokens.space5),
                child: AppPanel(
                  tone: AppPanelTone.dark,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _LoadingLottie(),
                      SizedBox(height: tokens.space2),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: AppColors.textInverse,
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

class _LoadingLottie extends StatelessWidget {
  const _LoadingLottie();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Lottie.asset(
        'assets/lotties/loading.lottie',
        fit: BoxFit.contain,
        repeat: true,
        decoder: (bytes) => LottieComposition.decodeZip(
          bytes,
          filePicker: (files) {
            return files.firstWhereOrNull(
              (f) =>
                  f.name.startsWith('animations/') && f.name.endsWith('.json'),
            );
          },
        ),
      ),
    );
  }
}
