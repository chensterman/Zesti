import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/widgets/formwidgets.dart';

class CreateGroup extends StatefulWidget {
  final String gid;
  CreateGroup({
    Key? key,
    required this.gid,
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: Text("Group Creation"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: size.height * CustomTheme.paddingMultiplier,
            horizontal: size.width * CustomTheme.paddingMultiplier),
        child: Form(
          key: _formKey,
          child: Center(
            child: ListView(shrinkWrap: true, children: <Widget>[
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Enter your group name:",
                        style: CustomTheme.textTheme.headline1,
                      ),
                    ),
                    TextFormField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Please enter a group name.";
                        }
                      },
                      onChanged: (val) {
                        setState(() => groupName = val);
                      },
                      decoration: const InputDecoration(hintText: "Group Name"),
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Enter a fun fact:",
                        style: CustomTheme.textTheme.headline1,
                      ),
                    ),
                    TextFormField(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter a fun fact.";
                          }
                        },
                        onChanged: (val) {
                          setState(() => funFact = val);
                        },
                        decoration:
                            const InputDecoration(hintText: "Fun Fact")),
                    SizedBox(height: 20.0),
                    RoundedButton(
                        text: 'Continue',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await DatabaseService(uid: user!.uid)
                                .createGroup(groupName, funFact);
                            Navigator.pop(context);
                          }
                        }),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
