import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/signup/phone.dart';
import 'package:zesti/views/signup/name.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Zesti",
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zesti'),
        backgroundColor: CustomTheme.lightTheme.primaryColor,
      ),
      body: Center(
          child: Container(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Phone()),
            );
          },
          child: Text("Signup"),
        ),
      )),
    );
  }
}
