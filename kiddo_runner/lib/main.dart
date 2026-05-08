import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/storage/storage_manager.dart';
import 'core/storage/music_manager.dart';
import 'core/theme/app_theme.dart';
import 'state/profile_provider.dart';
import 'state/settings_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline-first data stores
  await StorageManager.init();
  MusicManager.init();
  await MusicManager.preloadAudio();
  MusicManager.playMenuMusic();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const KiddoRunnerApp(),
    ),
  );
}

class KiddoRunnerApp extends StatelessWidget {
  const KiddoRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiddo Runner: Math & Words',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
