import 'package:app/features/notifications/domain/services/vibration_service.dart';
import 'package:vibration/vibration.dart';

class VibrationServiceImpl implements VibrationService {
  @override
  Future<void> vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }
}
