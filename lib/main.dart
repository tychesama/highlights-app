import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/record_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => RecordProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Highlights',
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}


