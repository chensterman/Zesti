import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';

class Create extends StatefulWidget {
  Create({
    Key? key,
  }) : super(key: key);

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<Create> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        title: Text("Group Creation"),
      ),
      body: Center(child: Text("Create")),
    );
  }
}
