import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:settings_ui/settings_ui.dart';

import 'history_view.dart';
import 'stats_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  var appBox = Hive.box('app_box');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('app_box').listenable(),
      builder: (context, box, widget) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Statistics',
            ),
          ),
          body: SafeArea(
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Appearance'),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        setState(() {
                          appBox.put('darkMode', value);
                        });
                      },
                      initialValue: appBox.get('darkMode') ?? false,
                      leading: const Icon(Icons.dark_mode),
                      title: const Text('Dark Mode'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.color_lens),
                      title: const Text('Accent Color'),
                      value: Text(
                          appBox.get('accentColorName') ?? 'Pink'
                      ),
                      onPressed: (context) => Navigator.pushNamed(context, 'accentColorView'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Symptoms & Meds'),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      leading: const Icon(Icons.medical_services),
                      title: const Text('Add Period Symptoms'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.medical_services),
                      title: const Text('Add PMS Symptoms'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.medication),
                      title: const Text('Add Medicines'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
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
                label: 'Tampon Timer',
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
            currentIndex: 4,
            onTap: (index) {
              if (index == 1) {
                Navigator.pushNamed(context, 'historyView');
              } else if (index == 2) {

              } else if (index == 3) {
                Navigator.pushNamed(context, 'statsView');
              } else if (index == 0) {
                Navigator.pushNamed(context, 'homeView');
              }
            },
          ),
        );
      },
    );

  }
}
