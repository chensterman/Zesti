import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zesti/views/home/home.dart';
import 'package:zesti/providers/cardposition.dart';

// CardWrapper class:
//  Needed so that the CardPositionProvider can
//  make the necessary updates to the user card
//  stack.
class CardWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Card position provider to listen to.
      create: (context) => CardPositionProvider(),
      // Generate the home page, passing the provider value.
      child: MaterialApp(
        home: Home(),
      ),
    );
  }
}
