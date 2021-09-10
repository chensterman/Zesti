import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/views/home/love/chat.dart';

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
    return Scaffold(
        // StreamBuilder to load match stream.
        body: StreamBuilder(
            stream: matches,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              QuerySnapshot? tmp = snapshot.data;
              return tmp != null
                  ? ListView.separated(
                      padding: EdgeInsets.all(16.0),
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
                        return matchSheet(widget.uid, data['chat-ref'],
                            data['first-name'], data['photo-ref']);
                      },
                      // A divider widgets is placed in between each matchsheet widget.
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: tmp.docs.length + 1)
                  // StreamBuilder loading indicator.
                  : Center(child: CircularProgressIndicator());
            }));
  }

  // To display info about each match you have.
  Widget matchSheet(
      String uid, DocumentReference chatRef, String name, String photoref) {
    print(photoref);
    // FutureBuilder used to retrieve profile photo of your match.
    return FutureBuilder(
        future: DatabaseService(uid: uid).getProfPic(photoref),
        builder: (context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
          // On error.
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
            // On success.
          } else if (snapshot.connectionState == ConnectionState.done) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                          uid: uid,
                          chatRef: chatRef,
                          name: name,
                          profpic: snapshot.data)),
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
                        backgroundImage: snapshot.data,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(name,
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
            );
            // On loading, return an empty container.
          } else {
            return Container();
          }
        });
  }
}
