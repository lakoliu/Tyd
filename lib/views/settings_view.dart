import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:vula/views/components/bottom_nav_bar.dart';


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
              lightTheme: const SettingsThemeData(
                titleTextColor: Colors.black,
              ),
              darkTheme: SettingsThemeData(
                settingsListBackground: Colors.grey[850],
                titleTextColor: Colors.white,
              ),
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
                      initialValue: appBox.get('darkMode', defaultValue: false),
                      activeSwitchColor: Theme.of(context).primaryColor,
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
          bottomNavigationBar: bottomNavBar(context, 4)
        );
      },
    );
  }
}
