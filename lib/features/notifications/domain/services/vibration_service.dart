import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

abstract class VibrationService {
  void vibrateLight();
  void vibrateSuccess();
}

class VibrationServiceImpl implements VibrationService {
  @override
  void vibrateLight() {
    if (kIsWeb) return;
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(duration: 15);
    });
  }

  @override
  void vibrateSuccess() {
    if (kIsWeb) return;
    Vibration.hasVibrator().then((has) {
      if (has == true) Vibration.vibrate(pattern: [0, 50, 100, 50]);
    });
  }
}
