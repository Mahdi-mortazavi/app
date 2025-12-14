import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app/features/progress_visualization/presentation/bloc/progress_bloc.dart';
import 'package:app/features/progress_visualization/presentation/bloc/progress_event.dart';
import 'package:app/features/progress_visualization/presentation/bloc/progress_state.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:app/core/theme/app_theme.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgressBloc(tasksBloc: context.read<TasksBloc>())
        ..add(LoadProgress()),
      child: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          if (state is ProgressLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProgressLoadSuccess) {
            return Column(
              children: [
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
                                _getBottomTitle(value.toInt(), state.view),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: const AxisTitles(),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: state.data
                          .asMap()
                          .entries
                          .map(
                            (e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.toDouble(),
                                  color: AppTheme.blue,
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
                  ),
                ),
                CupertinoSlidingSegmentedControl<ChartView>(
                  groupValue: state.view,
                  onValueChanged: (view) {
                    if (view != null) {
                      context.read<ProgressBloc>().add(ChangeChartView(view));
                    }
                  },
                  children: const {
                    ChartView.daily: Text('Daily'),
                    ChartView.weekly: Text('Weekly'),
                    ChartView.monthly: Text('Monthly'),
                  },
                ),
              ],
            );
          } else if (state is ProgressLoadFailure) {
            return const Center(child: Text('Failed to load progress.'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getBottomTitle(int i, ChartView view) {
    final Jalali j = Jalali.now();
    switch (view) {
      case ChartView.daily:
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
