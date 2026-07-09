import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
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

    return LiquidCanvas(
      child: Stack(
        children: [
          tasksAsync.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, _) => Center(
              child: EmptyState(
                icon: CupertinoIcons.exclamationmark_triangle,
                title: 'مشکلی پیش اومد',
                message: 'بارگذاری کارها با خطا مواجه شد.',
              ),
            ),
            data: (allTasks) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverPersistentHeader(
                  delegate: MinimalHeader(),
                  pinned: true,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                if (pinned.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: pinned.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => PinnedCard(task: pinned[i]),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                if (allTasks.isEmpty)
                  SliverFillRemaining(
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
                        child: Text('انجام شده', style: AppTypography.caption),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
              padding: const EdgeInsets.only(bottom: 28),
              child: LiquidGlassTap(
                onTap: () => openTaskSheet(context),
                borderRadius: BorderRadius.circular(32),
                blurSigma: 24,
                tint: AppColors.ink,
                tintOpacity: 0.85,
                padding: const EdgeInsets.all(18),
                child: const Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                  size: 30,
                ),
              ).animate().scale(
                    duration: 420.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
