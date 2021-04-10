import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';

/// This is the stateful widget that the main application instantiates.
class InputState extends StatefulWidget {
  const InputState({Key? key, @required this.width, @required this.hintText})
      : super(key: key);
  final width;
  final hintText;
  @override
  Input createState() => Input(width: width, hintText: hintText);
}

class Input extends State<InputState> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Input({@required this.width, @required this.hintText});
  final width;
  final hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 20, top: 15),
        width: width,
        child: TextFormField(
          decoration: new InputDecoration(
            isDense: true,
            hintText: hintText,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(width: 2.0, color: CustomTheme.gray),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  width: 2.0, color: CustomTheme.lightTheme.primaryColor),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(width: 2.0, color: Colors.white),
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ));
  }
}
