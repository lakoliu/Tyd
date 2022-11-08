import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tyd/helpers/database_initializers.dart';
import 'package:tyd/l10n/l10n.dart';
import 'package:tyd/timer_data.dart';
import 'package:tyd/views/history_view.dart';
import 'package:tyd/views/home_view.dart';
import 'package:tyd/day_data.dart';
import 'package:tyd/views/settings_view.dart';
import 'package:tyd/views/stats_view.dart';
import 'package:tyd/views/sub_settings/intervals_view.dart';
import 'package:tyd/views/sub_settings/medicines_view.dart';
import 'package:tyd/views/sub_settings/period_symptoms_view.dart';
import 'package:tyd/views/sub_settings/pms_settings_view.dart';
import 'package:tyd/views/sub_settings/tampon_size_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'helpers/color_adapter.dart';
import 'helpers/notification_service.dart';
import 'views/timer_view.dart';
import 'views/sub_settings/accent_color_view.dart';


void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DayDataAdapter());
  Hive.registerAdapter(TimerDataAdapter());
  Hive.registerAdapter(ColorAdapter());
  var dateBox = await Hive.openBox('date_box');
  var appBox = await Hive.openBox('app_box');
  await NotificationService().init();
  initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('app_box').listenable(),
      builder: (context, box, widget) {
        return MaterialApp(
          title: 'Tyd',
          themeMode: Hive.box('app_box').get('darkMode', defaultValue: false) ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            primaryColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
            primaryColorLight: Hive.box('app_box').get('accentColor') != null ? Hive.box('app_box').get('accentColor').withOpacity(0.3) : const Color(0xFF225500).withOpacity(0.3),
            appBarTheme: AppBarTheme(
              backgroundColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              unselectedItemColor: Colors.grey[600],
            ),
            pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(),}),
            buttonTheme: ButtonThemeData(
              buttonColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
                )
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              selectionHandleColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              selectionColor: Hive.box('app_box').get('accentColor').withOpacity(0.2) ?? const Color(0xFF225500).withOpacity(0.2),
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              hourMinuteColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                  ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                  : const Color(0xFF225500).withOpacity(0.2)
                  : Colors.grey[300]),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor')
                  : Colors.black),
              dayPeriodColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                  ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                  : const Color(0xFF225500).withOpacity(0.2)
                  : Colors.white),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500)
                  : Colors.grey[500]),
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              labelStyle: TextStyle(color: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
                )
              )
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              unselectedItemColor: Colors.white,
              backgroundColor: Colors.grey[800],
            ),
            pageTransitionsTheme: const PageTransitionsTheme(builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder(),}),
            buttonTheme: ButtonThemeData(
              buttonColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
                )
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              selectionHandleColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              selectionColor: Hive.box('app_box').get('accentColor').withOpacity(0.2) ?? const Color(0xFF225500).withOpacity(0.2),
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
              hourMinuteColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                  ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                  : const Color(0xFF225500).withOpacity(0.2)
                  : Colors.grey[300]),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor')
                  : Colors.black),
              dayPeriodColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                  ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                  : const Color(0xFF225500).withOpacity(0.2)
                  : Colors.white),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500)
                  : Colors.grey[500]),
            ),
            inputDecorationTheme: InputDecorationTheme(
                focusColor: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
                labelStyle: TextStyle(color: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Hive.box('app_box').get('accentColor') ?? const Color(0xFF225500),
                    )
                )
            ),
          ),
          supportedLocales: L10n.allLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          initialRoute: 'homeView',
          routes: {
            'homeView': (context) => const HomeView(),
            'historyView': (context) => const HistoryView(),
            'statsView': (context) => const StatsView(),
            'settingsView': (context) => const SettingsView(),
            'timerView': (context) => const TimerView(),
            'accentColorView': (context) => const AccentColorView(),
            'tamponSizeView': (context) => const TamponSizeView(),
            'periodSymptomsView': (context) => const PeriodSymptomsView(),
            'pmsSymptomsView': (context) => const PmsSymptomsView(),
            'medicinesView': (context) => const MedicinesView(),
            'intervalsView': (context) => const IntervalsView(),
          },
        );
      },
    );
  }
}