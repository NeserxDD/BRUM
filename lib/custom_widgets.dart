import 'package:flutter/material.dart';

class CustomInputDialog {
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String hintText = "",
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            backgroundColor: Color.fromARGB(255, 221, 231, 241),
            content: TextField(
              controller: controller,
              cursorColor: Colors.blue[700],
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  // Border when NOT focused
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 167, 205, 255),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  // Border when focused
                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                ),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Okay', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }
}

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(4),
          child: Text(message),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 2),
        elevation: 6,
      ),
    );
  }
}
