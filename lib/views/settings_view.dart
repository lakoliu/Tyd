import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:settings_ui/settings_ui.dart';
import 'package:tyd/helpers/constants.dart';
import 'package:tyd/helpers/export_helper.dart';
import 'package:tyd/helpers/import_helper.dart';
import 'package:tyd/helpers/update_stats.dart';
import 'package:tyd/views/components/bottom_nav_bar.dart';

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
      ))
          ?.files
          .single;
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
    var platform = Theme.of(context).platform;
    return ValueListenableBuilder(
      valueListenable: Hive.box('app_box').listenable(),
      builder: (context, box, widget) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.settings,
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
                  title: Text(AppLocalizations.of(context)!.appearance),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      onToggle: (value) {
                        setState(() {
                          appBox.put('darkMode', value);
                          var colorName = appBox.get('accentColorName');
                          if (value && colorName == 'Green') {
                            appBox.put('accentColor', Colors.pink[300]);
                            appBox.put('accentColorName', 'Pink');
                          }
                        });
                      },
                      initialValue: appBox.get('darkMode', defaultValue: false),
                      activeSwitchColor: Theme.of(context).primaryColor,
                      leading: const Icon(Icons.dark_mode),
                      title: Text(AppLocalizations.of(context)!.darkMode),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.color_lens),
                      title: Text(AppLocalizations.of(context)!.accentColor),
                      value: Text(appBox.get('accentColorName') ?? 'Green'),
                      onPressed: (context) =>
                          Navigator.pushNamed(context, 'accentColorView'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text(AppLocalizations.of(context)!.sympsMedsEtc),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      leading: const Icon(Icons.medical_services),
                      title: Text(
                          AppLocalizations.of(context)!.periodSymptomsSetting),
                      onPressed: (context) =>
                          Navigator.pushNamed(context, 'periodSymptomsView'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.medical_services),
                      title: Text(
                          AppLocalizations.of(context)!.pmsSymptomsSetting),
                      onPressed: (context) =>
                          Navigator.pushNamed(context, 'pmsSymptomsView'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.medication),
                      title: Text(AppLocalizations.of(context)!.medicines),
                      onPressed: (context) =>
                          Navigator.pushNamed(context, 'medicinesView'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text(AppLocalizations.of(context)!.times),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.timer),
                      title: Text(AppLocalizations.of(context)!.intervals),
                      value: platform == TargetPlatform.iOS
                          ? null
                          : Text(AppLocalizations.of(context)!.allSanitaryList),
                      onPressed: (context) =>
                          Navigator.pushNamed(context, 'intervalsView'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text(AppLocalizations.of(context)!.savedData),
                  tiles: [
                    SettingsTile.navigation(
                        leading: const Icon(Icons.download),
                        title: Text(AppLocalizations.of(context)!.importData),
                        value: Text(AppLocalizations.of(context)!.importFrom),
                        onPressed: (context) {
                          _selectedFile = null;
                          _selectedFileName = null;
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                    builder: (context, newSetState) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!
                                        .importFile),
                                    content: Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            pickAFile(newSetState);
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .browse),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: <Widget>[
                                              Flexible(
                                                child: Text(
                                                  _selectedFileName?.split(
                                                              path.extension(
                                                                  _selectedFileName!))[
                                                          0] ??
                                                      AppLocalizations.of(
                                                              context)!
                                                          .noFileSelected,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                path.extension(
                                                    _selectedFileName ?? ''),
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
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .cancelUpper),
                                      ),
                                      TextButton(
                                        onPressed: _selectedFile == null
                                            ? null
                                            : () {
                                                if (_selectedFile != null) {
                                                  ImportHelper.getJsonData(
                                                      context, _selectedFile!);
                                                  Navigator.pop(context);
                                                }
                                              },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .importUpper),
                                      ),
                                    ],
                                  );
                                });
                              });
                        }),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.upload),
                      title: Text(AppLocalizations.of(context)!.backupData),
                      onPressed: (context) =>
                          ExportHelper.exportSavedData(context),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.delete_forever),
                      title: Text(AppLocalizations.of(context)!.deleteData),
                      onPressed: (context) {
                        var deleteAllText = '';
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                builder: (context, newSetState) {
                              return AlertDialog(
                                title: Text(
                                    AppLocalizations.of(context)!.areYouSure),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(AppLocalizations.of(context)!
                                        .deleteAllData),
                                    TextField(
                                      textCapitalization:
                                          TextCapitalization.characters,
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
                                    onPressed: deleteAllText !=
                                            AppLocalizations.of(context)!
                                                .deleteUpper
                                        ? null
                                        : () {
                                            eraseAllDateBoxData();
                                            updateStats();
                                            Navigator.pop(context);
                                          },
                                    child: Text(AppLocalizations.of(context)!
                                        .deleteUpper),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(AppLocalizations.of(context)!
                                        .cancelUpper),
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
                  title: Text(AppLocalizations.of(context)!.reset),
                  tiles: [
                    SettingsTile.navigation(
                        leading: const Icon(Icons.lock_reset),
                        title: Text(AppLocalizations.of(context)!.resetAll),
                        onPressed: (context) {
                          var deleteAllText = '';
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                  builder: (context, newSetState) {
                                return AlertDialog(
                                  title: Text(
                                      AppLocalizations.of(context)!.areYouSure),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(AppLocalizations.of(context)!
                                          .resetAllSettings),
                                      TextField(
                                        textCapitalization:
                                            TextCapitalization.characters,
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
                                      onPressed: deleteAllText !=
                                              AppLocalizations.of(context)!
                                                  .deleteUpper
                                          ? null
                                          : () {
                                              resetAllSettings();
                                              Navigator.pop(context);
                                            },
                                      child: Text(AppLocalizations.of(context)!
                                          .deleteUpper),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(AppLocalizations.of(context)!
                                          .cancelUpper),
                                    ),
                                  ],
                                );
                              });
                            },
                          );
                        }),
                  ],
                ),
                SettingsSection(
                  title: Text(AppLocalizations.of(context)!.about),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.info),
                      title: Text(AppLocalizations.of(context)!.aboutTyd),
                      onPressed: (context) =>
                          Navigator.pushNamed(context, 'aboutView'),
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
