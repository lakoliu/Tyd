import 'package:flutter/material.dart';
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
        title: const Text(
          'Accent Color',
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Pink',
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
                'Blue',
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
            ListTile(
              title: Text(
                'Green',
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              leading: appBox.get('accentColorName') == 'Green' ? Icon(Icons.check, color: Colors.green[800]) : null,
              onTap: () {
                setState(() {
                  appBox.put('accentColor', Colors.green[800]);
                  appBox.put('accentColorName', 'Green');
                });
              },
            ),
            ListTile(
              title: Text(
                'Custom',
                style: TextStyle(
                  color: appBox.get('accentColorName') == 'Custom' ? appBox.get('accentColor') ?? Colors.black : Colors.black,
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
                      // content: SingleChildScrollView(
                      //   child: MaterialPicker(
                      //     pickerColor: appBox.get('accentColor') ?? Colors.pink[300],
                      //     onColorChanged: (color) {
                      //       setState(() {
                      //         appBox.put('accentColor', color);
                      //         appBox.put('accentColorName', 'Custom');
                      //       });
                      //     },
                      //     enableLabel: true,
                      //     portraitOnly: false,
                      //   ),
                      // ),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: appBox.get('accentColor') ?? Colors.pink[300],
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
