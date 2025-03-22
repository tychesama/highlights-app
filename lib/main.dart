import 'package:flutter/material.dart';
import 'package:highlight_marker/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'providers/record_provider.dart';
import 'providers/collection_provider.dart';
import 'screens/home_screen.dart';
import 'services/navigation_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordProvider()),
        ChangeNotifierProvider(create: (_) => CollectionProvider()),
      ],
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
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange[700],
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange[800],
          elevation: 6, // Shadow effect
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.orange[200]),
        ),
          colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.orange,
          onPrimary: Colors.white,
          secondary: Colors.amber,
          onSecondary: Colors.black,
          surface: Colors.black, 
          onSurface: Colors.white,
          error: Colors.red,
          onError: Colors.white,
        ),
      ),
      home: MainScreen(),
      navigatorKey: NavigationService.navigatorKey,
    );
  }
}


