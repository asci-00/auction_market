import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Shimmer.fromColors(
      baseColor: AppColors.bgMutedFor(brightness),
      highlightColor: AppColors.bgSurfaceFor(brightness),
      child: child,
    );
  }
}

class AppShimmerBlock extends StatelessWidget {
  const AppShimmerBlock({super.key, this.width, this.height, this.radius});

  final double? width;
  final double? height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgMutedFor(brightness),
        borderRadius: BorderRadius.circular(radius ?? tokens.cardRadius),
      ),
    );
  }
}

class AppShimmerCardPlaceholder extends StatelessWidget {
  const AppShimmerCardPlaceholder({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    return AppShimmer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.bgSurfaceFor(brightness),
          borderRadius: BorderRadius.circular(tokens.cardRadius),
          border: Border.all(color: AppColors.borderSoftFor(brightness)),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: AppShimmerBlock(radius: tokens.cardRadius)),
              SizedBox(height: tokens.space4),
              const AppShimmerBlock(width: 72, height: 12, radius: 999),
              SizedBox(height: tokens.space2),
              const AppShimmerBlock(height: 20, radius: 12),
              SizedBox(height: tokens.space2),
              const AppShimmerBlock(width: 140, height: 12, radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class AppShimmerListPlaceholder extends StatelessWidget {
  const AppShimmerListPlaceholder({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 120,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: List<Widget>.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index == itemCount - 1 ? 0 : tokens.space3,
          ),
          child: AppShimmerCardPlaceholder(height: itemHeight),
        ),
      ),
    );
  }
}
