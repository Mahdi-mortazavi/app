import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/task_providers.dart';

/// The small pill-shaped selector used in the task form. An inset fill chip
/// that inverts to a solid ink capsule when [active] — appearance-aware in
/// both states.
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
    final c = NavaColors.of(context);
    // Inverted capsule: ink background with canvas-colored content.
    final fg = active ? c.canvasTop : c.ink;

    return GestureDetector(
      onTap: () {
        ref.read(hapticsServiceProvider).selection();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? c.ink : c.fill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: active ? fg : c.inkSubdued,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
