import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/core/service_locator.dart' as di;
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/pages/home_page.dart';
import 'package:app/features/notifications/domain/services/notification_service.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await di.sl<NotificationService>().init();
  runApp(const IveApp());
}

class IveApp extends StatelessWidget {
  const IveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nava',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppDesign.background,
        primaryColor: AppDesign.blue,
        fontFamily: GoogleFonts.vazirmatn().fontFamily,
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverPersistentHeader(
                delegate: MinimalHeader(),
                pinned: true,
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 10)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: ProgressChart(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Pinned
              Consumer<TaskProvider>(
                builder: (ctx, prov, _) {
                  if (prov.pinnedTasks.isEmpty)
                    return const SliverToBoxAdapter();
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: prov.pinnedTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) =>
                            PinnedCard(task: prov.pinnedTasks[i]),
                      ),
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
              // Tasks
              Consumer<TaskProvider>(
                builder: (ctx, prov, _) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => TaskTile(task: prov.activeTasks[i]),
                        childCount: prov.activeTasks.length,
                      ),
                    ),
                  );
                },
              ),
              // Completed
              SliverToBoxAdapter(
                child: Consumer<TaskProvider>(
                  builder: (ctx, prov, _) => prov.completedTasks.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(24, 30, 24, 10),
                          child: Text(
                            "انجام شده",
                            style: TextStyle(
                              color: AppDesign.textSub,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
              Consumer<TaskProvider>(
                builder: (ctx, prov, _) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => TaskTile(
                          task: prov.completedTasks[i],
                          isDone: true,
                        ),
                        childCount: prov.completedTasks.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () => _openSheet(context),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppDesign.textMain,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(CupertinoIcons.add, color: Colors.white, size: 32),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}

enum ChartView { daily, weekly, monthly }

class ProgressChart extends StatefulWidget {
  const ProgressChart({super.key});

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  ChartView _view = ChartView.weekly;

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final data = _getChartData(tasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "نمودار پیشرفت",
          style: AppDesign.titleLarge.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                    rod.toY.round().toString(),
                    const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        _getBottomTitle(value.toInt()),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(),
              ),
              borderData: FlBorderData(show: false),
              barGroups: data
                  .mapIndexed(
                    (i, d) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: d.toDouble(),
                          color: AppDesign.blue,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              gridData: const FlGridData(show: false),
            ),
            swapAnimationDuration: 500.ms,
            swapAnimationCurve: Curves.easeInOut,
          ),
        ),
        const SizedBox(height: 20),
        CupertinoSlidingSegmentedControl<ChartView>(
          groupValue: _view,
          onValueChanged: (v) {
            if (v != null) setState(() => _view = v);
          },
          children: const {
            ChartView.daily: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("روزانه"),
            ),
            ChartView.weekly: Text("هفتگی"),
            ChartView.monthly: Text("ماهانه"),
          },
        ),
      ],
    );
  }

  List<int> _getChartData(List<Task> allTasks) {
    final now = DateTime.now();
    final completed =
        allTasks.where((t) => t.isCompleted && t.completionDate != null);

    switch (_view) {
      case ChartView.daily:
        return List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          return completed
              .where((t) =>
                  t.completionDate!.year == day.year &&
                  t.completionDate!.month == day.month &&
                  t.completionDate!.day == day.day)
              .length;
        });
      case ChartView.weekly:
        return List.generate(4, (i) {
          final weekStart = now.subtract(Duration(days: (now.weekday + 1) % 7 + (3 - i) * 7));
          return completed.where((t) {
            final cd = t.completionDate!;
            return cd.isAfter(weekStart) &&
                cd.isBefore(weekStart.add(const Duration(days: 7)));
          }).length;
        });
      case ChartView.monthly:
        return List.generate(6, (i) {
          final date = DateTime(now.year, now.month - (5 - i), 1);
          return completed
              .where((t) =>
                  t.completionDate!.year == date.year &&
                  t.completionDate!.month == date.month)
              .length;
        });
    }
  }

  String _getBottomTitle(int i) {
    final Jalali j = Jalali.now();
    switch (_view) {
      case ChartView.daily:
       // در پکیج shamsi_date برای کم کردن روز، باید روز منفی add کنید
return j.add(days: -(6 - i)).formatter.d.toString();
      case ChartView.weekly:
        return ["۴ هفته قبل", "۳ هفته قبل", "۲ هفته قبل", "این هفته"][i];
      case ChartView.monthly:
        final now = DateTime.now();
        final targetDate = DateTime(now.year, now.month - (5 - i), 1);
        final jalaliDate = Jalali.fromDateTime(targetDate);
        return jalaliDate.formatter.mN;
    }
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
          color: AppDesign.background.withOpacity(0.8),
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
                      color: AppDesign.textSub,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "کارها",
                  style: AppDesign.titleLarge.copyWith(fontSize: 34 - (10 * p)),
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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class PinnedCard extends StatelessWidget {
  final Task task;
  const PinnedCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context, task),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppDesign.card,
          borderRadius: AppDesign.radius,
          boxShadow: AppDesign.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).toggleComplete(task.id),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppDesign.green
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppDesign.green
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            CupertinoIcons.check_mark,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                Icon(
                  CupertinoIcons.pin_fill,
                  size: 14,
                  color: AppDesign.orange,
                ),
              ],
            ),
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${task.duration} دقیقه",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppDesign.textSub,
                  ),
                ),
                Hero(
                  tag: 'play_${task.id}',
                  child: GestureDetector(
                    onTap: () => _openFocus(context, task),
                    child: const Icon(
                      CupertinoIcons.play_circle_fill,
                      size: 26,
                      color: AppDesign.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TaskTile extends StatefulWidget {
  final Task task;
  final bool isDone;

  const TaskTile({super.key, required this.task, this.isDone = false});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: () {
            if (widget.task.subtasks.isNotEmpty)
              setState(() => _expanded = !_expanded);
          },
          onTap: () => _openSheet(context, widget.task),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppDesign.card,
              borderRadius: AppDesign.radius,
              boxShadow: AppDesign.softShadow,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).toggleComplete(widget.task.id),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.isDone ? AppDesign.green : Colors.transparent,
                      border: Border.all(
                        color: widget.isDone
                            ? AppDesign.green
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: widget.isDone
                        ? const Icon(
                            CupertinoIcons.check_mark,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration:
                              widget.isDone ? TextDecoration.lineThrough : null,
                          color: widget.isDone
                              ? AppDesign.textSub
                              : AppDesign.textMain,
                        ),
                      ),
                      if (!widget.isDone)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Text(
                                widget.task.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppDesign.textSub,
                                ),
                              ),
                              if (widget.task.reminder != null) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  CupertinoIcons.alarm,
                                  size: 12,
                                  color: AppDesign.textSub,
                                ),
                                Text(
                                  " ${widget.task.reminder!.hour}:${widget.task.reminder!.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppDesign.textSub,
                                  ),
                                ),
                              ],
                              if (widget.task.subtasks.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  CupertinoIcons.list_bullet,
                                  size: 12,
                                  color: AppDesign.textSub,
                                ),
                                Text(
                                  " ${widget.task.subtasks.where((e) => e.isCompleted).length}/${widget.task.subtasks.length}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppDesign.textSub,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (!widget.isDone)
                  Hero(
                    tag: 'play_${widget.task.id}',
                    child: GestureDetector(
                      onTap: () => _openFocus(context, widget.task),
                      child: const Icon(
                        CupertinoIcons.play_circle_fill,
                        size: 30,
                        color: AppDesign.textMain,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_expanded && widget.task.subtasks.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: widget.task.subtasks
                  .map(
                    (s) => ListTile(
                      dense: true,
                      leading: Icon(
                        s.isCompleted
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.circle,
                        color: s.isCompleted ? AppDesign.green : Colors.grey,
                        size: 18,
                      ),
                      title: Text(
                        s.title,
                        style: TextStyle(
                          decoration:
                              s.isCompleted ? TextDecoration.lineThrough : null,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () => Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).toggleSubTask(widget.task.id, s.id),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

// ==============================================================================
// 6. SHEET (Borderless & Clean)
// ==============================================================================

void _openSheet(BuildContext context, [Task? task]) {
  showCupertinoModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shadow: const BoxShadow(color: Colors.transparent),
    builder: (context) => TaskForm(task: task),
  );
}

class TaskForm extends StatefulWidget {
  final Task? task;
  const TaskForm({super.key, this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late TextEditingController _ctrl;
  String _cat = 'شخصی';
  int _dur = 25;
  bool _pin = false;
  DateTime? _rem;
  List<SubTask> _subs = [];

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _ctrl = TextEditingController(text: t?.title ?? '');
    if (t != null) {
      _cat = t.category;
      _dur = t.duration;
      _pin = t.isPinned;
      _rem = t.reminder;
      _subs = List.from(
        t.subtasks.map(
          (e) => SubTask(title: e.title, isCompleted: e.isCompleted),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task == null ? 'کار جدید' : 'ویرایش',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.task != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      child: const Icon(
                        CupertinoIcons.trash,
                        color: AppDesign.red,
                      ),
                      onPressed: () {
                        Provider.of<TaskProvider>(
                          context,
                          listen: false,
                        ).delete(widget.task!.id);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _ctrl,
                placeholder: 'عنوان کار...',
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                style: AppDesign.body,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _Badge(
                      _cat,
                      onTap: () => setState(
                        () => _cat = ['شخصی', 'کاری', 'خرید', 'مطالعه'][([
                                  'شخصی',
                                  'کاری',
                                  'خرید',
                                  'مطالعه',
                                ].indexOf(_cat) +
                                1) %
                            4],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      "$_dur دقیقه",
                      icon: CupertinoIcons.timer,
                      onTap: () => setState(
                        () => _dur = (_dur == 25
                            ? 45
                            : _dur == 45
                                ? 90
                                : 25),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      _pin ? "پین شده" : "پین",
                      icon: _pin ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                      active: _pin,
                      onTap: () => setState(() => _pin = !_pin),
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      _rem != null
                          ? "${_rem!.hour}:${_rem!.minute.toString().padLeft(2, '0')}"
                          : "یادآور",
                      icon: CupertinoIcons.alarm,
                      active: _rem != null,
                      onTap: _pickTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "زیرمجموعه (${_subs.where((e) => e.isCompleted).length}/${_subs.length})",
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppDesign.textSub,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    child: const Icon(
                      CupertinoIcons.add_circled,
                      color: AppDesign.blue,
                    ),
                    onPressed: _addSub,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_subs.isNotEmpty)
                ..._subs.map(
                  (s) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppDesign.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => s.isCompleted = !s.isCompleted),
                          child: Icon(
                            s.isCompleted
                                ? CupertinoIcons.check_mark_circled_solid
                                : CupertinoIcons.circle,
                            color:
                                s.isCompleted ? AppDesign.green : Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.title,
                            style: TextStyle(
                              decoration: s.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _subs.remove(s)),
                          child: const Icon(
                            CupertinoIcons.minus_circle,
                            color: AppDesign.red,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              CupertinoButton(
                color: AppDesign.textMain,
                borderRadius: BorderRadius.circular(16),
                onPressed: _save,
                child: const Text(
                  "ذخیره",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSub() {
    String t = "";
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("افزودن مورد"),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(autofocus: true, onChanged: (v) => t = v),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("لغو"),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("افزودن"),
            onPressed: () {
              if (t.isNotEmpty) setState(() => _subs.add(SubTask(title: t)));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 250,
        color: Colors.white,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          onDateTimeChanged: (t) {
            final now = DateTime.now();
            setState(
              () => _rem = DateTime(
                now.year,
                now.month,
                now.day,
                t.hour,
                t.minute,
              ),
            );
          },
        ),
      ),
    );
  }

  void _save() {
    if (_ctrl.text.isEmpty) return;
    final t = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch,
      title: _ctrl.text,
      category: _cat,
      duration: _dur,
      reminder: _rem,
      isPinned: _pin,
      isCompleted: widget.task?.isCompleted ?? false,
      subtasks: _subs,
    );

    final p = Provider.of<TaskProvider>(context, listen: false);
    if (widget.task == null)
      p.addTask(t);
    else
      p.updateTask(t);
    Navigator.pop(context);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const _Badge(
    this.label, {
    this.icon,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!kIsWeb) HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.black : AppDesign.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: active ? Colors.white : Colors.grey),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// 7. FOCUS MODE
// ==============================================================================

void _openFocus(BuildContext context, Task task) {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => FocusPage(task: task),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    ),
  );
}

class FocusPage extends StatefulWidget {
  final Task task;
  const FocusPage({super.key, required this.task});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  late int total, remaining;
  bool active = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    total = widget.task.duration * 60;
    remaining = total;
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (active && remaining > 0) {
        setState(() => remaining--);
      } else {
        t.cancel();
        if (remaining <= 0) {
          if (mounted) {
            setState(() => active = false);
          }
          if (!kIsWeb) Vibration.vibrate();
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Color get _glowColor {
    switch (widget.task.category) {
      case 'کاری':
        return AppDesign.blue;
      case 'خرید':
        return AppDesign.orange;
      case 'مطالعه':
        return AppDesign.purple;
      default:
        return AppDesign.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _glowColor.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: _glowColor.withOpacity(0.3),
                  blurRadius: 120,
                  spreadRadius: 20,
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                duration: 4.seconds,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.3, 1.3),
              ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: CupertinoButton(
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: Colors.white54,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),
                Hero(
                  tag: 'play_${widget.task.id}',
                  child: const Icon(
                    CupertinoIcons.play_circle_fill,
                    color: Colors.transparent,
                    size: 0,
                  ),
                ),
                Text(
                  widget.task.category,
                  style: TextStyle(
                    color: _glowColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 60),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularPercentIndicator(
                      radius: 140,
                      lineWidth: 6,
                      percent: remaining / total,
                      backgroundColor: Colors.white10,
                      progressColor:
                          remaining < 60 ? AppDesign.red : _glowColor,
                      circularStrokeCap: CircularStrokeCap.round,
                      animateFromLastPercent: true,
                      animation: true,
                      animationDuration: 1000,
                    ),
                    Text(
                      "${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}",
                      style: AppDesign.timerFont.copyWith(
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                if (remaining > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GlassBtn(
                        "-5",
                        () =>
                            setState(() => remaining = max(0, remaining - 300)),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: () {
                          if (!kIsWeb) HapticFeedback.mediumImpact();
                          setState(() => active = !active);
                          if (active) {
                            _startTimer();
                          } else {
                            timer?.cancel();
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Icon(
                                active
                                    ? CupertinoIcons.pause_fill
                                    : CupertinoIcons.play_fill,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      _GlassBtn("+5", () => setState(() => remaining += 300)),
                    ],
                  )
                else
                  CupertinoButton(
                    onPressed: () {
                      Provider.of<TaskProvider>(context, listen: false)
                          .toggleComplete(widget.task.id);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "اتمام",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GlassBtn(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
