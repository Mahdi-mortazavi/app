import 'package:flutter/material.dart';
import 'package:app/features/task_management/domain/entities/task.dart';
import 'package:app/features/task_management/presentation/widgets/pinned_card.dart';
import 'package:app/features/task_management/presentation/widgets/task_tile.dart';
import 'package:app/features/progress_visualization/presentation/widgets/progress_chart.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'dart:ui';
import 'package:app/core/theme/app_theme.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  const TaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final pinnedTasks = tasks.where((t) => t.isPinned && !t.isCompleted).toList();
    final activeTasks = tasks.where((t) => !t.isPinned && !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    return CustomScrollView(
      slivers: [
        const SliverPersistentHeader(
          delegate: MinimalHeader(),
          pinned: true,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: ProgressChart(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        if (pinnedTasks.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: pinnedTasks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => PinnedCard(task: pinnedTasks[i]),
              ),
            ),
          ),
        SliverToBoxAdapter(child: const SizedBox(height: 24)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => TaskTile(task: activeTasks[i]),
              childCount: activeTasks.length,
            ),
          ),
        ),
        if (completedTasks.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 10),
              child: Text(
                "انجام شده",
                style: TextStyle(
                  color: AppTheme.textSub,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => TaskTile(task: completedTasks[i], isDone: true),
              childCount: completedTasks.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class MinimalHeader extends SliverPersistentHeaderDelegate {
  const MinimalHeader();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final Jalali j = Jalali.now();
    final p = (shrinkOffset / 40).clamp(0.0, 1.0);
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: AppTheme.background.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: 1 - p,
                  child: Text(
                    "${j.formatter.wN}، ${j.formatter.d} ${j.formatter.mN}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSub,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "کارها",
                  style: AppTheme.titleLarge.copyWith(fontSize: 34 - (10 * p)),
                ),
              ],
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
