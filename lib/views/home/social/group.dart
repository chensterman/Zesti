import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:zesti/widgets/loading.dart';
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
        child: Center(
          child: ListView(shrinkWrap: true, children: <Widget>[
            Center(
              child: Column(
                children: [
                  SizedBox(height: size.height * CustomTheme.paddingMultiplier),
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    width: double.infinity,
                    child: Text('Your Group',
                        textAlign: TextAlign.left,
                        style: CustomTheme.textTheme.headline3),
                  ),
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
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "Change group name:",
                                style: CustomTheme.textTheme.headline2,
                              ),
                            ),
                            TextFormField(
                                onChanged: (val) {
                                  setState(() => groupName = val);
                                },
                                decoration: const InputDecoration(
                                    hintText: "Group Name")),
                            SizedBox(height: 20.0),
                            Center(
                              child: RoundedButton(
                                  text: 'Update',
                                  onPressed: () async {
                                    if (groupName.isEmpty) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => errorDialog(
                                              context,
                                              "Please enter a group name."));
                                    } else if (groupName.length > 50) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => errorDialog(
                                              context,
                                              "Please enter a shorter name (50 characters max)."));
                                    } else {
                                      ZestiLoadingAsync().show(context);
                                      await DatabaseService(uid: user.uid)
                                          .updateGroupName(
                                              widget.gid, groupName);
                                      ZestiLoadingAsync().dismiss();
                                      showDialog(
                                          context: context,
                                          builder: (context) => changeDialog(
                                              context, "Group name updated!"));
                                    }
                                  }),
                            ),
                            SizedBox(height: 50.0),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "Change group bio:",
                                style: CustomTheme.textTheme.headline2,
                              ),
                            ),
                            TextFormField(
                                onChanged: (val) {
                                  setState(() => groupTagline = val);
                                },
                                decoration: const InputDecoration(
                                    hintText: "Group Bio")),
                            SizedBox(height: 20.0),
                            Center(
                              child: RoundedButton(
                                  text: 'Update',
                                  onPressed: () async {
                                    if (groupTagline.isEmpty) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => errorDialog(
                                              context,
                                              "Please enter a group bio."));
                                    } else if (groupTagline.length > 140) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => errorDialog(
                                              context,
                                              "Please enter a shorter bio (140 characters max)."));
                                    } else {
                                      ZestiLoadingAsync().show(context);
                                      await DatabaseService(uid: user.uid)
                                          .updateGroupTagline(
                                              widget.gid, groupTagline);
                                      ZestiLoadingAsync().dismiss();

                                      showDialog(
                                          context: context,
                                          builder: (context) => changeDialog(
                                              context, "Group bio updated!"));
                                    }
                                  }),
                            ),
                            SizedBox(height: 50.0),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "Add a user:",
                                style: CustomTheme.textTheme.headline2,
                              ),
                            ),
                            TextFormField(
                                onChanged: (val) {
                                  setState(() => zestKey = val);
                                },
                                decoration:
                                    const InputDecoration(hintText: "ZestKey")),
                            SizedBox(height: 20.0),
                            Center(
                              child: RoundedButton(
                                  text: 'Add!',
                                  onPressed: () async {
                                    if (zestKey.isEmpty) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => errorDialog(
                                              context,
                                              "Please enter a ZestKey."));
                                    } else {
                                      ZestiLoadingAsync().show(context);
                                      String message = await DatabaseService(
                                              uid: user.uid)
                                          .addUserToGroup(widget.gid, zestKey);
                                      ZestiLoadingAsync().dismiss();

                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              changeDialog(context, message));
                                    }
                                  }),
                            ),
                            SizedBox(height: 20.0),
                            Center(
                              child: RoundedButton(
                                  text: 'Leave Group',
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            leaveConfirmDialog(
                                                context, user.uid));
                                  }),
                            ),
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

  Widget errorDialog(BuildContext context, String error) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(error),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child:
              SvgPicture.asset("assets/warning.svg", semanticsLabel: "Warning"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Ok", style: CustomTheme.textTheme.headline2),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget changeDialog(BuildContext context, String message) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(message),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: SvgPicture.asset("assets/name.svg", semanticsLabel: "Name"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Ok", style: CustomTheme.textTheme.headline2),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget leaveConfirmDialog(BuildContext context, String uid) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text("Are you sure you want to leave this group?"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child:
              SvgPicture.asset("assets/warning.svg", semanticsLabel: "Warning"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Yes", style: CustomTheme.textTheme.headline2),
          onPressed: () async {
            ZestiLoadingAsync().show(context);
            await DatabaseService(uid: uid).leaveGroup(widget.gid);
            ZestiLoadingAsync().dismiss();

            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Cancel", style: CustomTheme.textTheme.headline2),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
