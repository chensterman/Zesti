import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/views/home/love/chat.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/errors.dart';

// Widget displaying the chat page for a specific match.
class Matches extends StatefulWidget {
  final String uid;
  Matches({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  // Stream of match information (initialized during initState).
  Stream<QuerySnapshot>? matches;

  @override
  void initState() {
    matches = DatabaseService(uid: widget.uid).getMatches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
        // StreamBuilder to load match stream.
        child: StreamBuilder(
            stream: matches,
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
                            Center(
                                child: Text('MATCHES',
                                    style: CustomTheme.textTheme.headline3)),
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
                        return matchSheet(
                            widget.uid, data['chat-ref'], data['user-ref']);
                      },
                      // A divider widgets is placed in between each matchsheet widget.
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16.0),
                      itemCount: tmp.docs.length + 1)
                  // StreamBuilder loading indicator.
                  : Center(child: CircularProgressIndicator());
            }));
  }

  Widget recentChat(DocumentReference chatRef, DocumentReference userRef) {
    return StreamBuilder(
        stream: DatabaseService(uid: widget.uid).getMessages(chatRef),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          QuerySnapshot? tmp = snapshot.data;
          if (tmp != null) {
            Map<String, dynamic> data =
                tmp.docs.first.data() as Map<String, dynamic>;
            String message = data['content'];
            return Text(message,
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis);
          } else {
            return Container();
          }
        });
  }

  // To display info about each match you have.
  Widget matchSheet(
      String uid, DocumentReference chatRef, DocumentReference userRef) {
    // FutureBuilder used to retrieve profile photo of your match.
    final size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: DatabaseService(uid: uid).getUserInfo(userRef),
        builder: (context, AsyncSnapshot<ZestiUser> snapshot) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Chat(
                            uid: uid,
                            youid: userRef.id,
                            chatRef: chatRef,
                            name: snapshot.data!.first,
                            profpic: snapshot.data!.profPic)),
                  );
                },
                // Display match info (user data) on the sheet.
                child: Container(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundImage: snapshot.data!.profPic,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: size.width * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(snapshot.data!.first,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                              SizedBox(height: 10.0),
                              recentChat(chatRef, userRef),
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
