import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/features/task_management/data/datasources/task_local_data_source.dart';
import 'package:app/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:app/features/task_management/domain/repositories/task_repository.dart';
import 'package:app/features/task_management/domain/usecases/get_tasks.dart';
import 'package:app/features/task_management/domain/usecases/save_tasks.dart';
import 'package:app/features/task_management/presentation/bloc/tasks_bloc.dart';
import 'package:app/features/notifications/domain/services/notification_service.dart';
import 'package:app/features/notifications/domain/services/vibration_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(() => TasksBloc(
        getTasks: sl(),
        saveTasks: sl(),
        notificationService: sl(),
        vibrationService: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => SaveTasks(sl()));

  // Repositories
  sl.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(localDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<TaskLocalDataSource>(
      () => TaskLocalDataSourceImpl(sharedPreferences: sl()));

  // Services
  sl.registerLazySingleton<NotificationService>(() => NotificationServiceImpl());
  sl.registerLazySingleton<VibrationService>(() => VibrationServiceImpl());

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
