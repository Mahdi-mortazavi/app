import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Central place for every tactile response in the app. Screens/widgets call
/// semantic methods (`success`, `warning`, ...) instead of reaching for
/// `HapticFeedback`/`Vibration` directly, so the "feel" of the app can be
/// tuned in one file.
///
/// Falls back to the platform [HapticFeedback] API when a real vibration
/// motor isn't available (most iOS devices, web, or a check that hasn't
/// resolved yet) so every event still produces *some* tactile response.
class HapticsService {
  HapticsService();

  bool? _hasVibrator;

  Future<bool> get _canVibrate async {
    if (kIsWeb) return false;
    return _hasVibrator ??= await Vibration.hasVibrator() ?? false;
  }

  /// Micro click for selection/toggle changes (category chips, tab swaps).
  Future<void> selection() async {
    if (await _canVibrate) {
      unawaited(Vibration.vibrate(duration: 10, amplitude: 40));
    } else {
      HapticFeedback.selectionClick();
    }
  }

  /// Double light pulse — task completed, item saved, positive confirmation.
  Future<void> success() async {
    if (await _canVibrate) {
      unawaited(Vibration.vibrate(pattern: [0, 30, 60, 30], intensities: [0, 100, 0, 140]));
    } else {
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 90));
      HapticFeedback.lightImpact();
    }
  }

  /// Single heavy pulse — destructive action, error, or a warning prompt.
  Future<void> warning() async {
    if (await _canVibrate) {
      unawaited(Vibration.vibrate(duration: 60, amplitude: 220));
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  /// A soft, single tap — play/pause, minor UI interaction.
  Future<void> light() async {
    if (await _canVibrate) {
      unawaited(Vibration.vibrate(duration: 15, amplitude: 60));
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// Continuous elegant rhythm marking focus-session completion — distinct
  /// from `success` so a finished timer is unmistakable even in a pocket.
  Future<void> timerComplete() async {
    if (await _canVibrate) {
      unawaited(
        Vibration.vibrate(
          pattern: [0, 120, 90, 120, 90, 240],
          intensities: [0, 160, 0, 160, 0, 200],
        ),
      );
    } else {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      HapticFeedback.heavyImpact();
    }
  }
}
