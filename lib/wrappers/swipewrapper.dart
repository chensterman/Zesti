import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zesti/providers/cardposition.dart';
import 'package:zesti/views/home/home.dart';

// Wrapper class needed for the provider of card positioning/swiping
// Called after registration forms are done (in info.dart)
class SwipeWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardPositionProvider(),
      child: MaterialApp(
        home: Home(),
      ),
    );
  }
}
