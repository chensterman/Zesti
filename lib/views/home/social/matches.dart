import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestigroup.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/errors.dart';
import 'package:zesti/widgets/groupavatar.dart';
import 'package:zesti/views/home/social/chat.dart';
import 'package:zesti/widgets/loading.dart';

// Widget displaying the chat page for a specific match.
class Matches extends StatefulWidget {
  final String gid;
  Matches({
    Key? key,
    required this.gid,
  }) : super(key: key);

  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    return Container(
        // StreamBuilder to load match stream.
        child: StreamBuilder(
            stream: DatabaseService(uid: user!.uid).getGroupMatches(widget.gid),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              QuerySnapshot? tmp = snapshot.data;
              return tmp != null
                  ? ListView.separated(
                      padding: EdgeInsets.symmetric(
                          vertical: size.height * CustomTheme.paddingMultiplier,
                          horizontal:
                              size.width * CustomTheme.paddingMultiplier),
                      itemBuilder: (context, index) {
                        // First index is reserved for text "MATCHES".
                        if (index == 0) {
                          return Column(children: [
                            Container(
                              margin: EdgeInsets.only(left: 10.0),
                              width: double.infinity,
                              child: Text('Matches',
                                  textAlign: TextAlign.left,
                                  style: CustomTheme.textTheme.headline3),
                            ),
                            tmp.docs.length == 0
                                ? Empty(
                                    reason:
                                        "No matches  at the moment, but keep trying! For the discounts!")
                                : Container(),
                          ]);
                        }

                        // Remaining indeces used for matchsheet widgets.
                        Map<String, dynamic> data =
                            tmp.docs[index - 1].data() as Map<String, dynamic>;
                        return matchSheet(user.uid, data['chat-ref'],
                            data['group-ref'], tmp.docs[index - 1].reference);
                      },
                      // A divider widgets is placed in between each matchsheet widget.
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.0),
                      itemCount: tmp.docs.length + 1)
                  // StreamBuilder loading indicator.
                  : ZestiLoading();
            }));
  }

  Widget recentChat(String uid, DocumentReference chatRef) {
    return StreamBuilder(
        stream: DatabaseService(uid: uid).getMessages(chatRef),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          QuerySnapshot? tmp = snapshot.data;
          if (tmp != null) {
            if (tmp.docs.length == 0) {
              return Text("Send the first messsage!",
                  style: TextStyle(
                      fontSize: 16, color: CustomTheme.reallyBrightOrange),
                  overflow: TextOverflow.ellipsis);
            }
            Map<String, dynamic> data =
                tmp.docs.first.data() as Map<String, dynamic>;
            String message = data['content'];
            if (data['sender-ref'].id != uid) {
              return Text(message,
                  style: TextStyle(
                      fontSize: 16, color: CustomTheme.reallyBrightOrange),
                  overflow: TextOverflow.ellipsis);
            } else {
              return Text(message,
                  style: TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis);
            }
          } else {
            return Container();
          }
        });
  }

  // To display info about each match you have.
  Widget matchSheet(String uid, DocumentReference chatRef,
      DocumentReference groupRef, DocumentReference parentGroupRef) {
    // FutureBuilder used to retrieve profile photo of your match.
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: DatabaseService(uid: uid).getGroupInfo(groupRef),
        builder: (context, AsyncSnapshot<ZestiGroup> snapshot) {
          // On error.
          if (snapshot.hasError) {
            return NotFoundMatchSheet(doc: parentGroupRef);
            // On success.
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  ZestiGroup currGroup = await DatabaseService(uid: uid)
                      .getGroupInfo(DatabaseService(uid: uid)
                          .groupCollection
                          .doc(widget.gid));
                  Map<DocumentReference, String> yourGroupMap =
                      new Map<DocumentReference, String>.from(
                          currGroup.nameMap);
                  currGroup.nameMap.addAll(snapshot.data!.nameMap);
                  currGroup.photoMap.addAll(snapshot.data!.photoMap);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                              gid: widget.gid,
                              yougid: snapshot.data!.gid,
                              groupName: snapshot.data!.groupName,
                              chatRef: chatRef,
                              nameMap: currGroup.nameMap,
                              photoMap: currGroup.photoMap,
                              yourGroupMap: yourGroupMap,
                              youPhotoMap: snapshot.data!.photoMap,
                            )),
                  );
                },
                // Display match info (user data) on the sheet.
                child: Container(
                  child: Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GroupAvatar(
                              groupPhotos:
                                  snapshot.data!.photoMap.values.toList(),
                              radius: 80.0)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: size.width * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data!.groupName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                  overflow: TextOverflow.ellipsis),
                              SizedBox(height: 10.0),
                              recentChat(user!.uid, chatRef)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            // On loading, return an empty container.
          } else {
            return Container();
          }
        });
  }
}
