import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/liquid_glass.dart';
import '../../providers/task_providers.dart';
import '../navigation.dart';
import '../widgets/empty_state.dart';
import '../widgets/minimal_header.dart';
import '../widgets/pinned_card.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final pinned = ref.watch(pinnedTasksProvider);
    final active = ref.watch(activeTasksProvider);
    final completed = ref.watch(completedTasksProvider);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return LiquidCanvas(
      child: Stack(
        children: [
          tasksAsync.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, _) => const Center(
              child: EmptyState(
                icon: CupertinoIcons.exclamationmark_triangle,
                title: 'مشکلی پیش اومد',
                message: 'بارگذاری کارها با خطا مواجه شد. برای تلاش دوباره اپ را ببند و باز کن.',
              ),
            ),
            data: (allTasks) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverPersistentHeader(
                  delegate: MinimalHeader(),
                  pinned: true,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                if (pinned.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.gutter,
                        ),
                        itemCount: pinned.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (_, i) => PinnedCard(task: pinned[i]),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
                if (allTasks.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyState(
                        icon: CupertinoIcons.sparkles,
                        title: 'هنوز کاری نداری',
                        message: 'با دکمه‌ی پایین اولین کارت رو اضافه کن.',
                      ),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TaskTile(task: active[i]),
                        childCount: active.length,
                      ),
                    ),
                  ),
                  if (completed.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.gutter,
                          18,
                          AppSpacing.gutter,
                          AppSpacing.sm,
                        ),
                        child: Semantics(
                          header: true,
                          child: Text('انجام شده', style: AppTypography.caption),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TaskTile(task: completed[i], isDone: true),
                        childCount: completed.length,
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              // Respect the home-indicator / gesture inset so the button never
              // sits under the system UI on modern iPhones.
              padding: EdgeInsets.only(
                bottom: 20 + MediaQuery.of(context).padding.bottom,
              ),
              child: _AddButton(reduceMotion: reduceMotion),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.reduceMotion});

  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      label: 'افزودن کار جدید',
      child: LiquidGlassTap(
        onTap: () => openTaskSheet(context),
        borderRadius: BorderRadius.circular(AppRadius.sheet),
        blurSigma: 24,
        tint: AppColors.ink,
        tintOpacity: 0.85,
        padding: const EdgeInsets.all(18),
        child: const Icon(
          CupertinoIcons.add,
          color: CupertinoColors.white,
          size: 30,
        ),
      ),
    );

    if (reduceMotion) return button;
    return button.animate().scale(duration: 420.ms, curve: Curves.easeOutBack);
  }
}
