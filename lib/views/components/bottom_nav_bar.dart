import 'package:flutter/material.dart';

Widget bottomNavBar(BuildContext context, int navIndex) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: false,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month),
        label: 'Calendar',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.timer),
        label: 'Timer',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: 'Statistics',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
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