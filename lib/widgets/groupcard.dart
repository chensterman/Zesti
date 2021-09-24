import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestigroup.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/errors.dart';
import 'package:zesti/widgets/usercard.dart';

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
            if (snapshot.data!.groupPhotos.length > 1) {
              picHeight = picHeight * 0.5;
            }
            List<Widget> widgetList = [];
            for (ImageProvider<Object> photo in snapshot.data!.groupPhotos) {
              widgetList.add(_buildAvatar(photo, picHeight));
            }
            return InkWell(
              child: Container(
                height: height,
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
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
                                if (rec) {
                                  await DatabaseService(uid: user.uid)
                                      .outgoingGroupInteraction(
                                          gid, snapshot.data!.gid, false);
                                } else {
                                  await DatabaseService(uid: user.uid)
                                      .incomingGroupInteraction(
                                          gid, snapshot.data!.gid, false);
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: InkWell(
                              child: Icon(rec ? Icons.send : Icons.check_circle,
                                  color: rec ? Colors.blue : Colors.green,
                                  size: 64.0),
                              onTap: () async {
                                if (rec) {
                                  await DatabaseService(uid: user.uid)
                                      .outgoingGroupInteraction(
                                          gid, snapshot.data!.gid, true);
                                } else {
                                  await DatabaseService(uid: user.uid)
                                      .incomingGroupInteraction(
                                          gid, snapshot.data!.gid, true);
                                }
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
            return Container();
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
            groupOnCard.funFact,
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
            if (snapshot.data!.groupPhotos.length > 1) {
              picHeight = picHeight * 0.5;
            }
            List<Widget> widgetList = [];
            for (ImageProvider<Object> photo in snapshot.data!.groupPhotos) {
              widgetList.add(_buildAvatar(photo, picHeight));
            }
            return InkWell(
              child: Container(
                height: height,
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: CircularProgressIndicator()));
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
            groupOnCard.funFact,
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
