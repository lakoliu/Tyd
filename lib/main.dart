import 'package:flutter/material.dart';
import 'package:vula/helpers/database_initializers.dart';
import 'package:vula/views/history_view.dart';
import 'package:vula/views/home_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vula/day_data.dart';
import 'package:vula/views/settings_view.dart';
import 'package:vula/views/stats_view.dart';

import 'helpers/color_adapter.dart';
import 'views/sub_settings/accent_color_view.dart';


void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DayDataAdapter());
  Hive.registerAdapter(ColorAdapter());
  var dateBox = await Hive.openBox('date_box');
  var appBox = await Hive.openBox('app_box');
  initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var appBox = Hive.box('app_box');
    return ValueListenableBuilder(
      valueListenable: Hive.box('app_box').listenable(),
      builder: (context, box, widget) {
        return MaterialApp(
          title: 'Vula',
          themeMode: Hive.box('app_box').get('darkMode', defaultValue: false) ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            primaryColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
            appBarTheme: AppBarTheme(
              backgroundColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
              unselectedItemColor: Colors.grey[600],
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
              unselectedItemColor: Colors.white,
              backgroundColor: Colors.grey[800],
            ),
          ),
          // ThemeData.dark().copyWith(
          //   colorScheme: const ColorScheme.dark().copyWith(primary: Colors.pink[300]),
          // ),
          initialRoute: 'homeView',
          routes: {
            'homeView': (context) => const HomeView(),
            'historyView': (context) => const HistoryView(),
            'statsView': (context) => const StatsView(),
            'settingsView': (context) => const SettingsView(),
            // 'timerView': (context) => const TimerView(),
            'accentColorView': (context) => const AccentColorView(),
          },
        );
      },
    );
  }
}