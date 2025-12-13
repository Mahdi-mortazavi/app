import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_state.dart';
import 'package:app/features/task_management/presentation/widgets/task_list.dart';
import 'package:app/features/task_management/presentation/widgets/task_form.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TasksLoadSuccess) {
            return TaskList(tasks: state.tasks);
          } else if (state is TasksLoadFailure) {
            return const Center(child: Text('Failed to load tasks.'));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(context),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shadow: const BoxShadow(color: Colors.transparent),
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<TasksBloc>(context),
        child: const TaskForm(),
      ),
    );
  }
}
