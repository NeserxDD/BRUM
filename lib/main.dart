import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'history.dart'; // Import the HistoryPage
import 'route_observer.dart'; // Add this imp


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Department and Area Selector',
      navigatorObservers: [routeObserver], // Add RouteObserver
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      home: HistoryPage(),
     
    );
  }
}
