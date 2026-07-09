import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/task_providers.dart';

/// The small pill-shaped control used for category/duration/pin/reminder
/// selectors in the task form. A glass surface that inverts to a solid ink
/// fill when [active].
class GlassBadge extends ConsumerWidget {
  const GlassBadge(
    this.label, {
    super.key,
    this.icon,
    this.active = false,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(hapticsServiceProvider).selection();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : CupertinoColors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? CupertinoColors.transparent
                : CupertinoColors.white.withValues(alpha: 0.6),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: active ? CupertinoColors.white : AppColors.inkSubdued,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? CupertinoColors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
