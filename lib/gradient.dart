import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;

  GradientScaffold({required this.body, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
             Color.fromARGB(255, 189, 179, 149), Color.fromARGB(255, 246, 240, 240),
              Color.fromARGB(255, 242, 226, 177),
              Color.fromARGB(255, 213, 199, 163),
              Color.fromARGB(255, 189, 179, 149),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: body,
      ),
    );
  }
}