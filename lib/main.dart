import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';
import 'services/timer_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent storage via SharedPreferences
  final storageService = await StorageService.create();

  // Initialize business logic timer service
  final timerService = TimerService(storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StorageService>.value(value: storageService),
        ChangeNotifierProvider<TimerService>.value(value: timerService),
      ],
      child: const CountdownApp(),
    ),
  );
}

class CountdownApp extends StatelessWidget {
  const CountdownApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();

    return MaterialApp(
      title: 'Countdown Timer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storageService.themeMode,
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        HistoryScreen.routeName: (context) => const HistoryScreen(),
      },
    );
  }
}
