import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/widgets/formwidgets.dart';

class CreateGroup extends StatefulWidget {
  CreateGroup({
    Key? key,
  }) : super(key: key);

  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final _formKey = GlobalKey<FormState>();
  String groupName = '';
  String funFact = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: Text("Group Creation"),
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
                                    "Enter your group name:",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                TextFormField(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please enter a group name.";
                                    }
                                    if (val.length > 50) {
                                      return "Please enter a shorter name (50 characters max).";
                                    }
                                  },
                                  onChanged: (val) {
                                    setState(() => groupName = val);
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Group Name"),
                                ),
                                SizedBox(height: 20.0),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "Enter a group tagline:",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                TextFormField(
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return "Please enter a group tagline.";
                                      }
                                      if (val.length > 140) {
                                        return "Please enter a shorter tagline (140 characters max).";
                                      }
                                    },
                                    onChanged: (val) {
                                      setState(() => funFact = val);
                                    },
                                    decoration: const InputDecoration(
                                        hintText: "Tagline")),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                    text: 'Continue',
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await DatabaseService(uid: user!.uid)
                                            .createGroup(groupName, funFact);
                                        Navigator.of(context).pop();
                                      }
                                    }),
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
