import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zesti/models/zestigroup.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/home.dart';
import 'package:zesti/views/home/social/create.dart';
import 'package:zesti/views/home/social/social.dart';
import 'package:zesti/widgets/errors.dart';
import 'package:zesti/widgets/groupavatar.dart';

class Choose extends StatefulWidget {
  Choose({
    Key? key,
  }) : super(key: key);

  @override
  _ChooseState createState() => _ChooseState();
}

class _ChooseState extends State<Choose> {
  int groupCount = 0;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: Text("Group Selection"),
        actions: [
          InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => createDialog(context, groupCount));
              },
              child: Container(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.add_circle,
                  color: CustomTheme.reallyBrightOrange,
                  size: 26.0,
                ),
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              )),
          SizedBox(width: 20.0),
        ],
      ),
      body: StreamBuilder(
          stream: DatabaseService(uid: user!.uid).getGroups(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            QuerySnapshot? tmp = snapshot.data;
            if (tmp != null) {
              groupCount = tmp.docs.length;
              return Container(
                  width: size.width,
                  height: size.height,
                  decoration: CustomTheme.mode,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * CustomTheme.paddingMultiplier,
                        horizontal: size.width * CustomTheme.paddingMultiplier),
                    cacheExtent: size.height * 3,
                    itemCount: groupCount + 1,
                    itemBuilder: (context, index) {
                      if (groupCount == 0) {
                        return Empty(
                            reason:
                                "You are not in a blocking group. Try creating one yourself!");
                      }
                      if (index != groupCount) {
                        Map<String, dynamic> groupData =
                            tmp.docs[index].data() as Map<String, dynamic>;
                        return groupSlot(groupData['group-ref'], user.uid);
                      } else {
                        return Container();
                      }
                    },
                    // A divider widgets is placed in between each matchsheet widget.
                    separatorBuilder: (context, index) => Divider(),
                  ));
            } else {
              return Text("PROFILE INFO RETRIEVAL ERROR");
            }
          }),
    );
  }

  Widget groupSlot(DocumentReference groupRef, String uid) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        splashColor: CustomTheme.reallyBrightOrange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Social(gid: groupRef.id)),
          );
        },
        child: FutureBuilder(
            future: DatabaseService(uid: uid).getGroupInfo(groupRef),
            builder: (context, AsyncSnapshot<ZestiGroup> snapshot) {
              // On error.
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
                // On success.
              } else if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GroupAvatar(
                          radius: 160.0,
                          groupPhotos: snapshot.data!.photoMap.values.toList()),
                      SizedBox(height: 16.0),
                      Text(snapshot.data!.groupName,
                          textAlign: TextAlign.center,
                          style: CustomTheme.textTheme.headline3),
                    ],
                  ),
                );
              } else {
                return Padding(
                    padding: EdgeInsets.all(100.0),
                    child: Center(child: CircularProgressIndicator()));
              }
            }),
      ),
    );
  }

  Widget createDialog(BuildContext context, int groupCount) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(groupCount == 3
          ? "You are already in a maximum number of blocking groups."
          : "Create a new blocking group?"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: groupCount == 3
              ? SvgPicture.asset("assets/warning.svg",
                  semanticsLabel: "Warning")
              : SvgPicture.asset("assets/match.svg", semanticsLabel: "Match"),
        ),
      ),
      actions: groupCount == 3
          ? <Widget>[
              TextButton(
                child: Text("Ok", style: CustomTheme.textTheme.headline2),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]
          : <Widget>[
              TextButton(
                child: Text("Yes", style: CustomTheme.textTheme.headline1),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateGroup()),
                  );
                },
              ),
              TextButton(
                child: Text("No", style: CustomTheme.textTheme.headline2),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
    );
  }
}
