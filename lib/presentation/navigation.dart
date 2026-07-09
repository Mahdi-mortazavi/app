import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../data/models/task.dart';
import 'screens/focus_page.dart';
import 'widgets/task_form.dart';

void openTaskSheet(BuildContext context, [Task? task]) {
  showCupertinoModalBottomSheet(
    context: context,
    backgroundColor: CupertinoColors.transparent,
    builder: (context) => TaskForm(task: task),
  );
}

void openFocusPage(BuildContext context, Task task) {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => FocusPage(task: task),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}
