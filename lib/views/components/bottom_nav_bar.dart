import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget bottomNavBar(BuildContext context, int navIndex) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: false,
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.home),
        label: AppLocalizations.of(context)!.home,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.calendar_month),
        label: AppLocalizations.of(context)!.calendar,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.timer),
        label: AppLocalizations.of(context)!.timer,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.bar_chart),
        label: AppLocalizations.of(context)!.statistics,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: AppLocalizations.of(context)!.settings,
      ),
    ],
    currentIndex: navIndex,
    onTap: (index) {
      if (index != navIndex) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, 'homeView');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, 'historyView');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, 'timerView');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, 'statsView');
        } else if (index == 4) {
          Navigator.pushReplacementNamed(context, 'settingsView');
        }
      }
    },
  );
}
