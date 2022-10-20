import 'package:flutter/material.dart';
import 'package:vula/helpers/database_initializers.dart';
import 'package:vula/views/history_view.dart';
import 'package:vula/views/home_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vula/day_data.dart';
import 'package:vula/views/settings_view.dart';
import 'package:vula/views/stats_view.dart';

import 'helpers/color_adapter.dart';
import 'helpers/timer_view.dart';
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
            primaryColorLight: Hive.box('app_box').get('accentColor') != null ? Hive.box('app_box').get('accentColor').withOpacity(0.3) : Colors.pink[300]?.withOpacity(0.3),
            appBarTheme: AppBarTheme(
              backgroundColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
              unselectedItemColor: Colors.grey[600],
            ),
            pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(),}),
            buttonTheme: ButtonThemeData(
              buttonColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: Hive.box('app_box').get('accentColor') ?? Colors.pink[300],
              hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                      ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                      : Colors.pink[300]?.withOpacity(0.2)
                  : Colors.grey[300]),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor')
                  : Colors.black),
              dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                      ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                      : Colors.pink[300]?.withOpacity(0.2)
                  : Colors.white),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') ?? Colors.pink[300]
                  : Colors.grey[500]),
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
            pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(),}),
          ),
          initialRoute: 'homeView',
          routes: {
            'homeView': (context) => const HomeView(),
            'historyView': (context) => const HistoryView(),
            'statsView': (context) => const StatsView(),
            'settingsView': (context) => const SettingsView(),
            'timerView': (context) => const TimerView(),
            'accentColorView': (context) => const AccentColorView(),
          },
        );
      },
    );
  }
}