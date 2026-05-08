import 'dart:async';
import 'package:flutter/material.dart';
import '../core/storage/storage_manager.dart';
import '../core/storage/music_manager.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _soundEnabled = StorageManager.soundEnabled;
    _musicEnabled = StorageManager.musicEnabled;
    _dailyPlayLimitMinutes = StorageManager.dailyPlayLimitMinutes;
    _dailyPlayTimeSeconds = StorageManager.dailyPlayTimeSeconds;
    _startPlayTimer();
  }

  late bool _soundEnabled;
  late bool _musicEnabled;
  late int _dailyPlayLimitMinutes;
  late int _dailyPlayTimeSeconds;
  Timer? _timer;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  int get dailyPlayLimitMinutes => _dailyPlayLimitMinutes;
  int get dailyPlayTimeSeconds => _dailyPlayTimeSeconds;

  bool get isDailyLimitReached {
    StorageManager.resetExtraPlayIfNewDay();
    return _dailyPlayTimeSeconds >= (effectiveDailyPlayLimitMinutes * 60);
  }

  int get effectiveDailyPlayLimitMinutes {
    StorageManager.resetExtraPlayIfNewDay();
    return StorageManager.effectiveDailyPlayLimitMinutes;
  }

  bool get isExtraPlayUsedToday {
    StorageManager.resetExtraPlayIfNewDay();
    return StorageManager.isExtraPlayUsedToday;
  }

  Future<void> addExtraPlayMinutesToday(int minutes) async {
    await StorageManager.addExtraPlayMinutesToday(minutes);
    notifyListeners();
  }

  Future<void> resetExtraPlayIfNewDay() async {
    await StorageManager.resetExtraPlayIfNewDay();
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool val) async {
    _soundEnabled = val;
    await StorageManager.setSoundEnabled(val);
    notifyListeners();
  }

  Future<void> setMusicEnabled(bool val) async {
    _musicEnabled = val;
    await StorageManager.setMusicEnabled(val);
    if (val) {
      await MusicManager.playMenuMusic();
    } else {
      await MusicManager.stop();
    }
    notifyListeners();
  }

  Future<void> setDailyPlayLimitMinutes(int val) async {
    _dailyPlayLimitMinutes = val;
    await StorageManager.setDailyPlayLimitMinutes(val);
    notifyListeners();
  }

  void _startPlayTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _dailyPlayTimeSeconds++;
      await StorageManager.setDailyPlayTimeSeconds(_dailyPlayTimeSeconds);
      notifyListeners();
    });
  }

  Future<void> resetDailyTime() async {
    _dailyPlayTimeSeconds = 0;
    await StorageManager.setDailyPlayTimeSeconds(0);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
