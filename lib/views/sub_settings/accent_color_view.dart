import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AccentColorView extends StatefulWidget {
  const AccentColorView({Key? key}) : super(key: key);

  @override
  State<AccentColorView> createState() => _AccentColorViewState();
}

class _AccentColorViewState extends State<AccentColorView> {
  var appBox = Hive.box('app_box');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.accentColor,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            if (!appBox.get('darkMode', defaultValue: false)) ...[
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.green,
                  style: const TextStyle(
                    color: Color(0xFF225500),
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                leading: appBox.get('accentColorName') == 'Green' ? const Icon(Icons.check, color: Color(0xFF225500)) : null,
                onTap: () {
                  setState(() {
                    appBox.put('accentColor', const Color(0xFF225500));
                    appBox.put('accentColorName', 'Green');
                  });
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.blue,
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                leading: appBox.get('accentColorName') == 'Blue' ? Icon(Icons.check, color: Colors.blue[800]) : null,
                onTap: () {
                  setState(() {
                    appBox.put('accentColor', Colors.blue[800]);
                    appBox.put('accentColorName', 'Blue');
                  });
                },
              ),
            ] else ...[
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.teal,
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                leading: appBox.get('accentColorName') == 'Teal' ? const Icon(Icons.check, color: Colors.tealAccent) : null,
                onTap: () {
                  setState(() {
                    appBox.put('accentColor', Colors.tealAccent);
                    appBox.put('accentColorName', 'Teal');
                  });
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.purple,
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                leading: appBox.get('accentColorName') == 'Purple' ? const Icon(Icons.check, color: Colors.purpleAccent) : null,
                onTap: () {
                  setState(() {
                    appBox.put('accentColor', Colors.purpleAccent);
                    appBox.put('accentColorName', 'Purple');
                  });
                },
              ),
            ],
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.pink,
                style: TextStyle(
                  color: Colors.pink[300],
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              leading: appBox.get('accentColorName') == 'Pink' ? Icon(Icons.check, color: Colors.pink[300]) : null,
              onTap: () {
                setState(() {
                  appBox.put('accentColor', Colors.pink[300]);
                  appBox.put('accentColorName', 'Pink');
                });
              },
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.custom,
                style: TextStyle(
                  color: appBox.get('accentColorName') == 'Custom' ? appBox.get('accentColor') ?? Colors.black : null,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              leading: appBox.get('accentColorName') == 'Custom' ? Icon(Icons.check, color: appBox.get('accentColor') ?? Colors.black) : null,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      titlePadding: const EdgeInsets.all(0),
                      contentPadding: const EdgeInsets.all(0),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: appBox.get('accentColor') ?? const Color(0xFF225500),
                          onColorChanged: (color) {
                            setState(() {
                              appBox.put('accentColor', color);
                              appBox.put('accentColorName', 'Custom');
                            });
                          },
                          colorPickerWidth: 300,
                          pickerAreaHeightPercent: 0.7,
                          pickerAreaBorderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(2),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
