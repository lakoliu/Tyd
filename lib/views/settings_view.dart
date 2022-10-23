import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:vula/views/components/bottom_nav_bar.dart';
import 'package:vula/helpers/constants.dart';


class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  var appBox = Hive.box('app_box');

  void resetAllSettings() {
    appBox.put('darkMode', false);
    appBox.put('accentColorName', 'Pink');
    appBox.put('accentColor', Colors.pink[300]);
    appBox.put('tamponTimer', 4.0);
    appBox.put('padTimer', 4.0);
    appBox.put('cupTimer', 4.0);
    appBox.put('tamponSizes', tamponSizes);
    appBox.put('periodSymptoms', periodSymptoms);
    appBox.put('pmsSymptoms', pmsSymptoms);
    appBox.put('medicines', medicines);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('app_box').listenable(),
      builder: (context, box, widget) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Settings',
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
                  title: const Text('Symptoms, Meds, Etc.'),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      leading: const Icon(Icons.medical_services),
                      title: const Text('Period Symptoms'),
                      onPressed: (context) => Navigator.pushNamed(context, 'periodSymptomsView'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.medical_services),
                      title: const Text('PMS Symptoms'),
                      onPressed: (context) => Navigator.pushNamed(context, 'pmsSymptomsView'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.medication),
                      title: const Text('Medicines'),
                      onPressed: (context) => Navigator.pushNamed(context, 'medicinesView'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.photo_size_select_small),
                      title: const Text('Tampon Sizes'),
                      value: Text(
                          appBox.get('tamponSizes').skip(1).join(', '),
                      ),
                      onPressed: (context) => Navigator.pushNamed(context, 'tamponSizeView'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Times'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.timer),
                      title: const Text('Intervals'),
                      value: const Text('Tampons, pads, cups, and underwear'),
                      onPressed: (context) => Navigator.pushNamed(context, 'intervalsView'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Reset'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.lock_reset),
                      title: const Text('Reset All Settings'),
                      onPressed: (context) {
                        var deleteAllText = '';
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Are you sure?'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('This will erase all of your custom settings. Type "DELETE" to continue.'),
                                  TextField(
                                    textCapitalization: TextCapitalization.characters,
                                    onChanged: (value) => deleteAllText = value,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => deleteAllText == 'DELETE' ? resetAllSettings() : {},
                                  child: const Text('Delete'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            );
                          },
                        );
                      }
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
