import 'package:flutter/material.dart';
import 'package:vula/views/calendar_view.dart';

void main() {
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
        'home_page': (context) => const CalendarView(),
      },
    );
  }
}