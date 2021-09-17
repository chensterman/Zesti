import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestigroup.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/widgets/groupavatar.dart';

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
    return Container(
        // StreamBuilder to load match stream.
        child: StreamBuilder(
            stream: DatabaseService(uid: user!.uid).getGroupMatches(widget.gid),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              QuerySnapshot? tmp = snapshot.data;
              return tmp != null
                  ? ListView.separated(
                      padding: EdgeInsets.all(8.0),
                      itemBuilder: (context, index) {
                        // First index is reserved for text "MATCHES".
                        if (index == 0) {
                          return Center(
                              child: Text('MATCHES',
                                  style: TextStyle(color: Colors.orange[900])));
                        }

                        // Remaining indeces used for matchsheet widgets.
                        Map<String, dynamic> data =
                            tmp.docs[index - 1].data() as Map<String, dynamic>;
                        return matchSheet(
                            user.uid, data['chat-ref'], data['group-ref']);
                      },
                      // A divider widgets is placed in between each matchsheet widget.
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.0),
                      itemCount: tmp.docs.length + 1)
                  // StreamBuilder loading indicator.
                  : Center(child: CircularProgressIndicator());
            }));
  }

  // To display info about each match you have.
  Widget matchSheet(
      String uid, DocumentReference chatRef, DocumentReference groupRef) {
    // FutureBuilder used to retrieve profile photo of your match.
    return FutureBuilder(
        future: DatabaseService(uid: uid).getGroupInfo(groupRef),
        builder: (context, AsyncSnapshot<ZestiGroup> snapshot) {
          // On error.
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
            // On success.
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => Chat(
                  //           uid: uid,
                  //           chatRef: chatRef,
                  //           name: snapshot.data!.first,
                  //           profpic: snapshot.data!.profPic)),
                  // );
                },
                // Display match info (user data) on the sheet.
                child: Container(
                  child: Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GroupAvatar(
                              groupPhotos: snapshot.data!.groupPhotos,
                              radius: 80.0)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(snapshot.data!.groupName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            SizedBox(height: 10.0),
                            Text('Hi there!', style: TextStyle(fontSize: 16))
                          ],
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
