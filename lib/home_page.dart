import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key}); // 🔹 `super.key` helps with widget reconstruction

  @override
  State<HomePage> createState() => _homepage();
}

class _homepage extends State<HomePage> {
  String text = "Welcome!";

  void changeText() {
    setState(() {
      text = "Flutter is awesome!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            ElevatedButton(onPressed: changeText, child: const Text("Change Text")),
          ],
        ),
      ),
    );
  }
}
