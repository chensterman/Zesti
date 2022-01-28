import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/register/zestkey.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:zesti/widgets/loading.dart';

// Widget for profile picture upload and bio
class Info extends StatefulWidget {
  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  // Form widget key.
  final _formKey = GlobalKey<FormState>();

  // Image variables.
  dynamic profpic;

  // Mutable bio.
  String bio = '';

  void profpicCallback(dynamic val) {
    setState(() {
      profpic = val;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 32.0),
                                  child: Text(
                                    "Upload your best picture...",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 64.0),
                                  child: ImageUpdate(
                                      callback: profpicCallback,
                                      profpic: profpic),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 32.0),
                                  child: Text(
                                    "and say something cool!",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                TextFormField(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please enter a bio.";
                                    }
                                    if (val.length > 140) {
                                      return "Please enter a shorter bio (140 characters max).";
                                    }
                                  },
                                  onChanged: (val) {
                                    setState(() => bio = val);
                                  },
                                  decoration:
                                      const InputDecoration(hintText: "Bio"),
                                ),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                  text: "Continue",
                                  onPressed: () async {
                                    // Form validation:
                                    //  Does nothing if validation is incorrect.
                                    if (_formKey.currentState!.validate()) {
                                      // Do not upload if dynamic imageFile is null.
                                      ZestiLoadingAsync().show(context);
                                      if (profpic != null) {
                                        // Update user document with the reference.
                                        await DatabaseService(uid: user!.uid)
                                            .updatePhoto(profpic);
                                      }
                                      // Update user document with bio.
                                      await DatabaseService(uid: user!.uid)
                                          .updateBio(bio);
                                      // Flag account as fully set up
                                      await DatabaseService(uid: user.uid)
                                          .updateAccountSetup();
                                      ZestiLoadingAsync().dismiss();
                                      // Navigate accordingly.
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ZestKey()),
                                      );
                                    }
                                  },
                                )
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
