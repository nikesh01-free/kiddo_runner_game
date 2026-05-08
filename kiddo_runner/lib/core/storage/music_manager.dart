import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import 'storage_manager.dart';

class MusicManager {
  static bool get _isMusicEnabled => StorageManager.musicEnabled;
  static bool get _isSoundEnabled => StorageManager.soundEnabled;

  static String? _currentMusicName;

  static void init() {
    try {
      FlameAudio.bgm.initialize();
      FlameAudio.bgm.audioPlayer.onPlayerComplete.listen((event) async {
        if (_isMusicEnabled && _currentMusicName != null) {
          try {
            await FlameAudio.bgm.audioPlayer.seek(const Duration(seconds: 1));
            await FlameAudio.bgm.audioPlayer.resume();
          } catch (e) {
            debugPrint('Error looping track to 1s: $e');
          }
        }
      });
    } catch (e) {
      debugPrint('Error initializing FlameAudio bgm: $e');
    }
  }

  static Future<void> preloadAudio() async {
    FlameAudio.audioCache.prefix = 'assets/audio/';
    final files = [
      'button_tap.wav',
      'coin.wav',
      'correct.wav',
      'wrong.wav',
      'level_complete.wav',
      'background_music.mp3',
      'in_level_game_background_music.mp3',
    ];
    for (final file in files) {
      try {
        await FlameAudio.audioCache.load(file);
        debugPrint('Preloaded audio successfully: $file');
      } catch (e) {
        debugPrint('Audio failed to preload: $file. Error: $e');
      }
    }
  }

  static Future<void> playMenuMusic() async {
    if (!_isMusicEnabled) {
      await stopMusic();
      return;
    }
    if (_currentMusicName == 'background_music.mp3') {
      debugPrint('background_music.mp3 is already playing, skipping restart.');
      return;
    }
    try {
      FlameAudio.audioCache.prefix = 'assets/audio/';
      _currentMusicName = 'background_music.mp3';
      debugPrint('Playing background_music.mp3');
      await FlameAudio.bgm.play('background_music.mp3', volume: 0.5);
      await FlameAudio.bgm.audioPlayer.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('Audio failed: background_music.mp3. Error: $e');
    }
  }

  static Future<void> playGameMusic() async {
    if (!_isMusicEnabled) {
      await stopMusic();
      return;
    }
    if (_currentMusicName == 'in_level_game_background_music.mp3') {
      debugPrint(
        'in_level_game_background_music.mp3 is already playing, skipping restart.',
      );
      return;
    }
    try {
      FlameAudio.audioCache.prefix = 'assets/audio/';
      _currentMusicName = 'in_level_game_background_music.mp3';
      debugPrint('Playing in_level_game_background_music.mp3');
      await FlameAudio.bgm.play(
        'in_level_game_background_music.mp3',
        volume: 0.5,
      );
      await FlameAudio.bgm.audioPlayer.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('Audio failed: in_level_game_background_music.mp3. Error: $e');
    }
  }

  static Future<void> playSfx(String filename) async {
    if (!_isSoundEnabled) return;
    try {
      FlameAudio.audioCache.prefix = 'assets/audio/';
      debugPrint('Playing SFX: $filename');
      await FlameAudio.play(filename, volume: 0.8);
    } catch (e) {
      debugPrint('Audio failed: $filename. Error: $e');
    }
  }

  static Future<void> stopMusic() async {
    try {
      _currentMusicName = null;
      await FlameAudio.bgm.stop();
    } catch (_) {}
  }

  static Future<void> stop() async {
    await stopMusic();
  }
}
