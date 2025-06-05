import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'history.dart'; // Import the HistoryPage
import 'route_observer.dart'; // Add this imp


Future<void> main() async {
  // Required for async operations before runApp()

  

  
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Department and Area Selector',
      navigatorObservers: [routeObserver], // Add RouteObserver
      theme: ThemeData(
        fontFamily: 'Montserrat',
     textTheme: TextTheme(
 
    displayLarge: TextStyle(fontWeight: FontWeight.w300),
    displayMedium: TextStyle(fontWeight: FontWeight.w300),
    titleLarge: TextStyle(fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(), 
    labelSmall: TextStyle(),
    bodyMedium: TextStyle(), 
    
  ),
      ),
      home: HistoryPage(),
     
    );
  }
}
