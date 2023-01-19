import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tyd/day_data.dart';
import 'package:tyd/helpers/database_initializers.dart';
import 'package:tyd/l10n/l10n.dart';
import 'package:tyd/timer_data.dart';
import 'package:tyd/views/history_view.dart';
import 'package:tyd/views/home_view.dart';
import 'package:tyd/views/settings_view.dart';
import 'package:tyd/views/stats_view.dart';
import 'package:tyd/views/sub_settings/about_view.dart';
import 'package:tyd/views/sub_settings/intervals_view.dart';
import 'package:tyd/views/sub_settings/medicines_view.dart';
import 'package:tyd/views/sub_settings/period_symptoms_view.dart';
import 'package:tyd/views/sub_settings/pms_symptoms_view.dart';

import 'helpers/color_adapter.dart';
import 'helpers/constants.dart';
import 'helpers/notification_service.dart';
import 'views/sub_settings/accent_color_view.dart';
import 'views/timer_view.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DayDataAdapter());
  Hive.registerAdapter(TimerDataAdapter());
  Hive.registerAdapter(ColorAdapter());
  await Hive.openBox('date_box');
  await Hive.openBox('app_box');
  await NotificationService().init();
  initializeDatabase();
  runApp(const Tyd());
}

class Tyd extends StatelessWidget {
  const Tyd({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('app_box').listenable(),
      builder: (context, box, widget) {
        return MaterialApp(
          title: 'Tyd',
          themeMode: Hive.box('app_box').get('darkMode', defaultValue: false)
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
            primaryColor:
                Hive.box('app_box').get('accentColor') ?? defaultColor,
            primaryColorLight: Hive.box('app_box').get('accentColor') != null
                ? Hive.box('app_box').get('accentColor').withOpacity(0.3)
                : defaultColor.withOpacity(0.3),
            appBarTheme: AppBarTheme(
              backgroundColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
              unselectedItemColor: Colors.grey[600],
            ),
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            }),
            buttonTheme: ButtonThemeData(
              buttonColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Hive.box('app_box').get('accentColor') ?? defaultColor,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
              foregroundColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
            )),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
              selectionHandleColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
              selectionColor:
                  Hive.box('app_box').get('accentColor').withOpacity(0.2) ??
                      defaultColor.withOpacity(0.2),
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
              hourMinuteColor: MaterialStateColor.resolveWith((states) => states
                      .contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                      ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                      : defaultColor.withOpacity(0.2)
                  : Colors.grey[300]),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Hive.box('app_box').get('accentColor')
                      : Colors.black),
              dayPeriodColor: MaterialStateColor.resolveWith((states) => states
                      .contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                      ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                      : defaultColor.withOpacity(0.2)
                  : Colors.white),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Hive.box('app_box').get('accentColor') ?? defaultColor
                      : Colors.grey[500]),
            ),
            inputDecorationTheme: InputDecorationTheme(
                focusColor:
                    Hive.box('app_box').get('accentColor') ?? defaultColor,
                labelStyle: TextStyle(
                  color: Hive.box('app_box').get('accentColor') ?? defaultColor,
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                  color: Hive.box('app_box').get('accentColor') ?? defaultColor,
                ))),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor:
                Hive.box('app_box').get('accentColor') ?? defaultColor,
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
              unselectedItemColor: Colors.white,
              backgroundColor: Colors.grey[800],
            ),
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            }),
            buttonTheme: ButtonThemeData(
              buttonColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Hive.box('app_box').get('accentColor') ?? defaultColor,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
              foregroundColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
            )),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
              selectionHandleColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
              selectionColor:
                  Hive.box('app_box').get('accentColor').withOpacity(0.2) ??
                      defaultColor.withOpacity(0.2),
            ),
            timePickerTheme: TimePickerThemeData(
              dialHandColor:
                  Hive.box('app_box').get('accentColor') ?? defaultColor,
              hourMinuteColor: MaterialStateColor.resolveWith((states) => states
                      .contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                      ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                      : defaultColor.withOpacity(0.2)
                  : Colors.grey[300]),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Hive.box('app_box').get('accentColor')
                      : Colors.black),
              dayPeriodColor: MaterialStateColor.resolveWith((states) => states
                      .contains(MaterialState.selected)
                  ? Hive.box('app_box').get('accentColor') != null
                      ? Hive.box('app_box').get('accentColor').withOpacity(0.2)
                      : defaultColor.withOpacity(0.2)
                  : Colors.white),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                  states.contains(MaterialState.selected)
                      ? Hive.box('app_box').get('accentColor') ?? defaultColor
                      : Colors.grey[500]),
            ),
            inputDecorationTheme: InputDecorationTheme(
                focusColor:
                    Hive.box('app_box').get('accentColor') ?? defaultColor,
                labelStyle: TextStyle(
                  color: Hive.box('app_box').get('accentColor') ?? defaultColor,
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                  color: Hive.box('app_box').get('accentColor') ?? defaultColor,
                ))),
          ),
          supportedLocales: L10n.allLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          initialRoute: 'homeView',
          routes: {
            'homeView': (context) => const HomeView(),
            'historyView': (context) => const HistoryView(),
            'statsView': (context) => const StatsView(),
            'settingsView': (context) => const SettingsView(),
            'timerView': (context) => const TimerView(),
            'accentColorView': (context) => const AccentColorView(),
            'periodSymptomsView': (context) => const PeriodSymptomsView(),
            'pmsSymptomsView': (context) => const PmsSymptomsView(),
            'medicinesView': (context) => const MedicinesView(),
            'intervalsView': (context) => const IntervalsView(),
            'aboutView': (context) => const AboutView(),
          },
        );
      },
    );
  }
}
