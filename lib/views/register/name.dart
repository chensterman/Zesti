import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/views/register/intents.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:zesti/widgets/loading.dart';

// Widget for name form
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
        backgroundColor: CustomTheme.reallyBrightOrange,
      ),
      body: Container(
        decoration: CustomTheme.mode,
        child: Center(
          child: Container(
            child: Form(
              key: _formKey,
              child: Center(
                child: ListView(shrinkWrap: true, children: <Widget>[
                  Center(
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: EdgeInsets.all(32.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32.0, horizontal: 32.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "What's your name?",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                TextFormField(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please enter a first name.";
                                    }
                                    if (val.length > 50) {
                                      return "Really sorry - could you shorten your name a bit? :(";
                                    }
                                  },
                                  onChanged: (val) {
                                    setState(() => first = val);
                                  },
                                  decoration:
                                      const InputDecoration(hintText: "First"),
                                ),
                                SizedBox(height: 20.0),
                                TextFormField(
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Please enter a last name.";
                                      }
                                      if (val.length > 140) {
                                        return "Please enter a shorter bio (140 characters max).";
                                      }
                                    },
                                    onChanged: (val) {
                                      setState(() => last = val);
                                    },
                                    decoration: const InputDecoration(
                                        hintText: "Last")),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                    text: 'Continue',
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        if (user == null) {
                                          print("Error");
                                        } else {
                                          ZestiLoadingAsync().show(context);
                                          await DatabaseService(uid: user.uid)
                                              .updateName(first, last);
                                          ZestiLoadingAsync().dismiss();
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Intents()),
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
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
