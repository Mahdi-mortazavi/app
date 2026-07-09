import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class MinimalHeader extends SliverPersistentHeaderDelegate {
  const MinimalHeader();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final Jalali j = Jalali.now();
    final collapse = (shrinkOffset / 40).clamp(0.0, 1.0);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.canvasTop.withValues(alpha: 0.75),
                AppColors.canvasTop.withValues(alpha: 0.45),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.white.withValues(alpha: 0.4 * collapse),
                width: 0.6,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: 1 - collapse,
                      child: Text(
                        '${j.formatter.wN}، ${j.formatter.d} ${j.formatter.mN}',
                        style: AppTypography.caption,
                      ),
                    ),
                    Text(
                      'کارها',
                      style: AppTypography.largeTitle.copyWith(
                        fontSize: 34 - (10 * collapse),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 130;

  @override
  double get minExtent => 90;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
