import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        fontFamily: 'LXGWWenKaiMono',
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
