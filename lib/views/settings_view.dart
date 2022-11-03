import 'package:flutter/material.dart';
import 'package:tyd/helpers/export_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tyd/helpers/import_helper.dart';
import 'package:tyd/helpers/update_stats.dart';
import 'package:tyd/views/components/bottom_nav_bar.dart';
import 'package:tyd/helpers/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;


class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  var appBox = Hive.box('app_box');
  var dateBox = Hive.box('date_box');
  PlatformFile? _selectedFile;
  String? _selectedFileName;


  void resetAllSettings() {
    appBox.put('darkMode', false);
    appBox.put('accentColorName', 'Green');
    appBox.put('accentColor', const Color(0xFF225500));
    appBox.put('tamponTimer', 4.0);
    appBox.put('padTimer', 4.0);
    appBox.put('cupTimer', 4.0);
    appBox.put('tamponSizes', tamponSizes);
    appBox.put('periodSymptoms', periodSymptoms);
    appBox.put('pmsSymptoms', pmsSymptoms);
    appBox.put('medicines', medicines);
  }
  
  void eraseAllDateBoxData() {
    dateBox.clear();
  }

  void pickAFile(void Function(void Function()) newState) async {
    PlatformFile? pickedFile;
    try {
      pickedFile = (await FilePicker.platform.pickFiles(
        type: FileType.any,
        // allowedExtensions: ['json', 'cluedata'],
      ))?.files.single;
    } catch (e) {
      pickedFile = null;
    }

    newState(() {
      _selectedFile = pickedFile;
      _selectedFileName = _selectedFile?.name;
    });
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
                          appBox.get('accentColorName') ?? 'Green'
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
                  title: const Text('Saved Data'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.download),
                      title: const Text('Import Data'),
                      value: const Text('Import data from XXX or another app'),
                      onPressed: (context) {
                        _selectedFile = null;
                        _selectedFileName = null;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder: (context, newSetState) {
                              return AlertDialog(
                                title: const Text('Import A File'),
                                content: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        pickAFile(newSetState);
                                      },
                                      child: const Text('Browse'),
                                    ),
                                    const SizedBox(width: 5.0,),
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                              _selectedFileName?.split(path.extension(_selectedFileName!))[0] ?? 'No file selected',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            path.extension(_selectedFileName ?? ''),
                                            // style: Theme.of(context).textTheme.caption,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: _selectedFile == null ? null : () {
                                      if (_selectedFile != null) {
                                        ImportHelper.getJsonData(context, _selectedFile!);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Import'),
                                  ),
                                ],
                              );
                            });
                          }
                        );
                      }
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.upload),
                      title: const Text('Back Up Data'),
                      onPressed: (context) => ExportHelper.exportSavedData(context),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.delete_forever),
                      title: const Text('Delete All Data'),
                      onPressed: (context) {
                        var deleteAllText = '';
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder: (context, newSetState) {
                              return AlertDialog(
                                title: const Text('Are you sure?'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('This will erase ALL of the data you have recorded. Type "DELETE" to continue.'),
                                    TextField(
                                      textCapitalization: TextCapitalization.characters,
                                      onChanged: (value) {
                                        newSetState(() {
                                          deleteAllText = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: deleteAllText != 'DELETE' ? null : () {
                                      eraseAllDateBoxData();
                                      updateStats();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('DELETE'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('CANCEL'),
                                  ),
                                ],
                              );
                            });
                          },
                        );
                      },
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
                            return StatefulBuilder(builder: (context, newSetState) {
                              return AlertDialog(
                                title: const Text('Are you sure?'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('This will erase all of your custom settings. Type "DELETE" to continue.'),
                                    TextField(
                                      textCapitalization: TextCapitalization.characters,
                                      onChanged: (value) {
                                        newSetState(() {
                                          deleteAllText = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: deleteAllText != 'DELETE' ? null : () {
                                      resetAllSettings();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('DELETE'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('CANCEL'),
                                  ),
                                ],
                              );
                            });
                          },
                        );
                      }
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: bottomNavBar(context, 4),
        );
      },
    );
  }
}
