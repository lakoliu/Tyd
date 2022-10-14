import 'package:flutter/material.dart';
import 'package:vula/views/history_view.dart';
import 'package:vula/views/home_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vula/day_data.dart';


void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DayDataAdapter());
  var dateBox = await Hive.openBox('date_box');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vula',
      theme: ThemeData(
        // primarySwatch: Colors.pink.shade300,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.pink[300],
        ),
      ),
      initialRoute: 'home_page',
      routes: {
        'home_page': (context) => const HomeView(),
        'history_page': (context) => const HistoryView(),
      },
    );
  }
}