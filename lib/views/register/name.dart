import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/views/register/birthday.dart';
import 'package:zesti/widgets/formwidgets.dart';

class Name extends StatefulWidget {
  @override
  _NameState createState() => _NameState();
}

class _NameState extends State<Name> {
  final _formKey = GlobalKey<FormState>();
  String first = '';
  String last = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
          width: size.width * CustomTheme.containerWidth,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "What's your name?",
                    style: CustomTheme.lightTheme.textTheme.headline1,
                  ),
                ),
                TextFormField(
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please enter a first name.";
                    }
                  },
                  onChanged: (val) {
                    setState(() => first = val);
                  },
                  decoration: const InputDecoration(hintText: "First"),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Please enter a last name.";
                      }
                    },
                    onChanged: (val) {
                      setState(() => last = val);
                    },
                    decoration: const InputDecoration(hintText: "Last")),
                SizedBox(height: 20.0),
                RoundedButton(
                    text: 'Continue',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (user == null) {
                          print("Error");
                        } else {
                          await DatabaseService(uid: user.uid)
                              .updateName(first, last);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Birthday()),
                        );
                      }
                    }),
                SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.3,
                  child: SvgPicture.asset("assets/name.svg",
                      semanticsLabel: "Name"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
