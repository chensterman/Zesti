import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:zesti/views/home/social/choose.dart';
import 'package:zesti/widgets/groupcard.dart';

class Group extends StatefulWidget {
  final String gid;
  Group({
    Key? key,
    required this.gid,
  }) : super(key: key);

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {
  final _formKey = GlobalKey<FormState>();
  String zestKey = '';
  String groupName = '';
  String groupTagline = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * CustomTheme.paddingMultiplier),
      child: Form(
        key: _formKey,
        child: Center(
          child: ListView(shrinkWrap: true, children: <Widget>[
            Center(
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  GroupCardDummy(
                      groupRef: DatabaseService(uid: user!.uid)
                          .groupCollection
                          .doc(widget.gid)),
                  SizedBox(height: 50.0),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: size.height * CustomTheme.paddingMultiplier,
                          horizontal:
                              size.width * CustomTheme.paddingMultiplier),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Change group tagline:",
                            style: CustomTheme.textTheme.headline2,
                          ),
                        ),
                        TextFormField(
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter a group tagline.";
                              }
                            },
                            onChanged: (val) {
                              setState(() => groupTagline = val);
                            },
                            decoration: const InputDecoration(
                                hintText: "Group Tagline")),
                        SizedBox(height: 20.0),
                        RoundedButton(
                            text: 'Update',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await DatabaseService(uid: user.uid)
                                    .updateGroupTagline(
                                        widget.gid, groupTagline);
                              }
                            }),
                        SizedBox(height: 50.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Change group name:",
                            style: CustomTheme.textTheme.headline2,
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
                            decoration:
                                const InputDecoration(hintText: "Group Name")),
                        SizedBox(height: 20.0),
                        RoundedButton(
                            text: 'Update',
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await DatabaseService(uid: user.uid)
                                    .updateGroupName(widget.gid, groupName);
                              }
                            }),
                        SizedBox(height: 50.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Add a user:",
                            style: CustomTheme.textTheme.headline2,
                          ),
                        ),
                        TextFormField(
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter a ZestKey.";
                              }
                            },
                            onChanged: (val) {
                              setState(() => zestKey = val);
                            },
                            decoration:
                                const InputDecoration(hintText: "ZestKey")),
                        SizedBox(height: 20.0),
                        RoundedButton(
                            text: 'Add!',
                            onPressed: () async {
                              await DatabaseService(uid: user.uid)
                                  .addUserToGroup(widget.gid, zestKey);
                            }),
                        SizedBox(height: 20.0),
                        RoundedButton(
                            text: 'Leave Group',
                            onPressed: () async {
                              await DatabaseService(uid: user.uid)
                                  .leaveGroup(widget.gid);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Choose()),
                              );
                            }),
                        SizedBox(height: 20.0)
                      ]),
                    ),
                  ),
                  SizedBox(height: 50.0),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
