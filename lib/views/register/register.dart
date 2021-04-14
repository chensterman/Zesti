import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';

class Signup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone'),
        backgroundColor: CustomTheme.lightTheme.primaryColor,
      ),
    );
  }
}
