import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestigroup.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/errors.dart';
import 'package:zesti/widgets/loading.dart';
import 'package:zesti/widgets/usercard.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget displaying user cards to make decisions on.
class GroupCard extends StatelessWidget {
  final String gid;
  final DocumentReference groupRef;
  final DocumentReference parentGroupRef;
  final bool rec;

  GroupCard({
    required this.gid,
    required this.groupRef,
    required this.parentGroupRef,
    required this.rec,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    // FutureBuilder used to fetch user photo from Firebase storage.
    return FutureBuilder(
        future: DatabaseService(uid: user!.uid).getGroupInfo(groupRef),
        builder: (context, AsyncSnapshot<ZestiGroup> snapshot) {
          // On error.
          if (snapshot.hasError) {
            return NotFound(
                reason: "It looks like this group just disbanded :(",
                doc: parentGroupRef);
          }
          // On success.
          else if (snapshot.connectionState == ConnectionState.done) {
            double height = size.height * 0.7;
            double picHeight = height;
            if (snapshot.data!.photoMap.length > 1) {
              picHeight = picHeight * 0.5;
            }
            List<Widget> widgetList = [];
            for (ImageProvider<Object> photo
                in snapshot.data!.photoMap.values) {
              widgetList.add(_buildAvatar(photo, picHeight));
            }
            return InkWell(
              child: Container(
                height: height,
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              widgetList.length >= 1
                                  ? widgetList[0]
                                  : Container(),
                              widgetList.length >= 3
                                  ? widgetList[2]
                                  : Container(),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              widgetList.length >= 2
                                  ? widgetList[1]
                                  : Container(),
                              widgetList.length >= 4
                                  ? widgetList[3]
                                  : Container(),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      // Box decoraion and gradient.
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, spreadRadius: 0.5),
                        ],
                        gradient: LinearGradient(
                          colors: [Colors.black12, Colors.black87],
                          begin: Alignment.center,
                          stops: [0.4, 1],
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Container(),
                    ),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => reportDialog(
                                    context,
                                    "Report this group?",
                                    user.uid,
                                    groupRef.id));
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.more_horiz,
                              size: 30.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                          )),
                    ),
                    Positioned(
                      right: 10,
                      left: 10,
                      bottom: 10,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: buildGroupInfo(snapshot.data!)),
                          // If "rec" is true, we display user cards meant for match recommendations.
                          // Otherwise, the user card is for incoming match requests. They look slightly different
                          // And the buttons call different database functions.
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: InkWell(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.red, size: 64.0),
                              onTap: () async {
                                ZestiLoadingAsync().show(context);
                                if (rec) {
                                  await DatabaseService(uid: user.uid)
                                      .outgoingGroupInteraction(
                                          gid, snapshot.data!.gid, false);
                                } else {
                                  await DatabaseService(uid: user.uid)
                                      .incomingGroupInteraction(
                                          gid, snapshot.data!.gid, false);
                                }
                                ZestiLoadingAsync().dismiss();
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: InkWell(
                              child: Icon(rec ? Icons.send : Icons.check_circle,
                                  color: rec ? Colors.blue : Colors.green,
                                  size: 64.0),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => sendDialog(
                                        context,
                                        rec
                                            ? "Match request sent to " +
                                                snapshot.data!.groupName +
                                                "!"
                                            : "Your group matched with " +
                                                snapshot.data!.groupName +
                                                "!",
                                        user.uid,
                                        gid,
                                        snapshot.data!.gid));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupUsers(
                          uid: user.uid,
                          gid: groupRef.id,
                          groupName: snapshot.data!.groupName)),
                );
              },
            );
          }
          // On loading, return an empty container.
          else {
            return Container(
                height: size.height * 0.7,
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: ZestiLoading());
          }
        });
  }

  Widget _buildAvatar(ImageProvider<Object> photo, double avatarHeight) {
    return Expanded(
        child: Container(
      height: avatarHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: photo,
        ),
      ),
    ));
  }

  // Put user information onto the cards.
  Widget buildGroupInfo(ZestiGroup groupOnCard) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Column displaying user info
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${groupOnCard.groupName}',
            style: CustomTheme.textTheme.subtitle1,
          ),
          SizedBox(height: 8),
          Text(
            groupOnCard.groupTagline,
            style: CustomTheme.textTheme.subtitle2,
          ),
          SizedBox(height: 4),
          Text(
            '',
            style: CustomTheme.textTheme.subtitle2,
          )
        ],
      ),
    );
  }

  Widget sendDialog(BuildContext context, String message, String uid,
      String gid, String yougid) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(message),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: rec
              ? SvgPicture.asset("assets/phone.svg", semanticsLabel: "Request")
              : SvgPicture.asset("assets/match.svg", semanticsLabel: "Match"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Nice!", style: CustomTheme.textTheme.headline2),
          onPressed: () async {
            ZestiLoadingAsync().show(context);
            if (rec) {
              await DatabaseService(uid: uid)
                  .outgoingGroupInteraction(gid, yougid, true);
            } else {
              await DatabaseService(uid: uid)
                  .incomingGroupInteraction(gid, yougid, true);
            }
            ZestiLoadingAsync().dismiss();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// Widget displaying user cards to make decisions on.
class GroupCardDummy extends StatelessWidget {
  final DocumentReference groupRef;

  GroupCardDummy({
    required this.groupRef,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    // FutureBuilder used to fetch user photo from Firebase storage.
    return FutureBuilder(
        future: DatabaseService(uid: user!.uid).getGroupInfo(groupRef),
        builder: (context, AsyncSnapshot<ZestiGroup> snapshot) {
          // On error.
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          // On success.
          else if (snapshot.connectionState == ConnectionState.done) {
            double height = size.height * 0.7;
            double picHeight = height;
            if (snapshot.data!.photoMap.length > 1) {
              picHeight = picHeight * 0.5;
            }
            List<Widget> widgetList = [];
            for (ImageProvider<Object> photo
                in snapshot.data!.photoMap.values) {
              widgetList.add(_buildAvatar(photo, picHeight));
            }
            return InkWell(
              child: Container(
                height: height,
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              widgetList.length >= 1
                                  ? widgetList[0]
                                  : Container(),
                              widgetList.length >= 3
                                  ? widgetList[2]
                                  : Container(),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              widgetList.length >= 2
                                  ? widgetList[1]
                                  : Container(),
                              widgetList.length >= 4
                                  ? widgetList[3]
                                  : Container(),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      // Box decoraion and gradient.
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, spreadRadius: 0.5),
                        ],
                        gradient: LinearGradient(
                          colors: [Colors.black12, Colors.black87],
                          begin: Alignment.center,
                          stops: [0.4, 1],
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Container(),
                    ),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => reportDialog(
                                    context,
                                    "Report this group?",
                                    user.uid,
                                    groupRef.id));
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.more_horiz,
                              size: 30.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                          )),
                    ),
                    Positioned(
                      right: 10,
                      left: 10,
                      bottom: 10,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: buildGroupInfo(snapshot.data!)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupUsers(
                        uid: user.uid,
                        gid: groupRef.id,
                        groupName: snapshot.data!.groupName),
                  ),
                );
              },
            );
          }
          // On loading, return an empty container.
          else {
            return Container(
                height: size.height * 0.7,
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: ZestiLoading());
          }
        });
  }

  Widget _buildAvatar(ImageProvider<Object> photo, double avatarHeight) {
    return Expanded(
        child: Container(
      height: avatarHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: photo,
        ),
      ),
    ));
  }

  // Put user information onto the cards.
  Widget buildGroupInfo(ZestiGroup groupOnCard) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Column displaying user info
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${groupOnCard.groupName}',
            style: CustomTheme.textTheme.subtitle1,
          ),
          SizedBox(height: 8),
          Text(
            groupOnCard.groupTagline,
            style: CustomTheme.textTheme.subtitle2,
          ),
          SizedBox(height: 4),
          Text(
            '',
            style: CustomTheme.textTheme.subtitle2,
          )
        ],
      ),
    );
  }
}

class GroupUsers extends StatefulWidget {
  final String uid;
  final String gid;
  final String groupName;
  GroupUsers({
    Key? key,
    required this.uid,
    required this.gid,
    required this.groupName,
  }) : super(key: key);

  @override
  _GroupUsersState createState() => _GroupUsersState();
}

class _GroupUsersState extends State<GroupUsers> {
  // Stream of match information (initialized during initState).
  Stream<QuerySnapshot>? groupUsers;

  @override
  void initState() {
    groupUsers = DatabaseService(uid: widget.uid).getGroupUsers(widget.gid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: Text(widget.groupName),
      ),
      body: StreamBuilder(
          stream: groupUsers,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            QuerySnapshot? tmp = snapshot.data;
            if (tmp != null) {
              return Container(
                  width: size.width,
                  height: size.height,
                  decoration: CustomTheme.mode,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.0),
                    cacheExtent: size.height * 0.7 * 3,
                    itemCount: tmp.docs.length,
                    itemBuilder: (context, index) {
                      print(tmp.docs[index].id);
                      return UserCardDummy(
                          userRef: DatabaseService(uid: user!.uid)
                              .userCollection
                              .doc(tmp.docs[index].id));
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
}

// Global widget used by both regular and dummy group cards.
Widget reportDialog(
    BuildContext context, String message, String uid, String gid) {
  // Text field controller for reasoning.
  TextEditingController reasonController = TextEditingController();

  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: Text(message),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: double.infinity,
              height: 150.0,
              child: SvgPicture.asset("assets/warning.svg",
                  semanticsLabel: "Report")),
          SizedBox(height: 20.0),
          TextFormField(
            controller: reasonController,
            decoration: InputDecoration(
                hintText: "(Optional) What's wrong?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
          ),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text("Cancel", style: CustomTheme.textTheme.headline2),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: Text("Confirm", style: CustomTheme.textTheme.headline1),
        onPressed: () async {
          ZestiLoadingAsync().show(context);
          await DatabaseService(uid: uid).report(
            "group",
            reasonController.text,
            DatabaseService(uid: uid).userCollection.doc(uid),
            DatabaseService(uid: uid).groupCollection.doc(gid),
          );
          ZestiLoadingAsync().dismiss();
          Navigator.of(context).pop();
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => reportStatusDialog(context));
        },
      ),
    ],
  );
}

// Global widget used by both regular and dummy group cards.
Widget reportStatusDialog(BuildContext context) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: Text("You feedback is under review!"),
    content: SingleChildScrollView(
      child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: SvgPicture.asset("assets/tos.svg",
              semanticsLabel: "Under Review")),
    ),
    actions: <Widget>[
      TextButton(
        child: Text("Ok", style: CustomTheme.textTheme.headline1),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
