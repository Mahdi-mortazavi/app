import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/liquid_glass.dart';
import '../../providers/task_providers.dart';

/// Contextual "soft ask" shown right before a feature that needs
/// notifications (setting a reminder), instead of firing the native OS
/// prompt cold on first launch. If the OS permission is already granted
/// this resolves instantly with no UI.
///
/// Returns true if the app is clear to schedule a notification.
Future<bool> ensureNotificationPermission(BuildContext context, WidgetRef ref) async {
  final service = ref.read(notificationServiceProvider);
  if (await service.hasPermission()) return true;
  if (!context.mounted) return false;

  final primed = await showCupertinoModalPopup<bool>(
    context: context,
    barrierColor: CupertinoColors.black.withValues(alpha: 0.35),
    builder: (context) => const _PermissionPrimerSheet(),
  );

  if (primed != true) return false;
  return service.requestPermission();
}

class _PermissionPrimerSheet extends StatelessWidget {
  const _PermissionPrimerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: LiquidGlass(
          borderRadius: BorderRadius.circular(28),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.bell_circle_fill,
                size: 44,
                color: AppColors.accentBlue,
              ),
              const SizedBox(height: 14),
              Text(
                'یادآوری‌های دقیق',
                style: AppTypography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'برای اینکه دقیقاً سر وقت یادت بیاریم، اجازه‌ی ارسال اعلان لازم داریم.',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(16),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'فعال‌سازی اعلان‌ها',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CupertinoButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('فعلاً نه', style: AppTypography.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
