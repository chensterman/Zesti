import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/views/home/home.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for name form
class ZestKey extends StatefulWidget {
  @override
  _ZestKeyState createState() => _ZestKeyState();
}

class _ZestKeyState extends State<ZestKey> {
  final _formKey = GlobalKey<FormState>();
  String zestKey = '';
  bool zestKeyFlag = true;

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
                                    "Finally, choose a ZestKey! This is how other users will add you to groups.",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                TextFormField(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please enter a ZestKey.";
                                    }
                                    if (zestKeyFlag)
                                      return "This ZestKey is already taken.";
                                  },
                                  onChanged: (val) {
                                    setState(() => zestKey = val);
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "A unique username"),
                                ),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                    text: "I'm Ready!",
                                    onPressed: () async {
                                      bool tmp =
                                          await DatabaseService(uid: user!.uid)
                                              .checkZestKey(zestKey);
                                      setState(() {
                                        zestKeyFlag = tmp;
                                      });
                                      if (_formKey.currentState!.validate()) {
                                        await DatabaseService(uid: user.uid)
                                            .updateZestKey(zestKey);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Home()),
                                        );
                                      }
                                    }),
                                SizedBox(height: 50.0),
                                SizedBox(
                                    width: double.infinity,
                                    height: size.height * 0.3,
                                    child:
                                        SvgPicture.asset("assets/zestkey.svg")),
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
