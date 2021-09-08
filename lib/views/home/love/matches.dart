import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/views/home/love/chat.dart';

// Widget displaying the chat page for a specific match
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
  TextEditingController messageText = TextEditingController();
  Stream<QuerySnapshot>? matches;

  @override
  void initState() {
    matches = DatabaseService(uid: widget.uid).getMatches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: matches,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              QuerySnapshot? tmp = snapshot.data;
              return tmp != null
                  ? ListView.separated(
                      padding: EdgeInsets.all(16.0),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Center(
                              child: Text('MATCHES',
                                  style: TextStyle(color: Colors.orange[900])));
                        }
                        Map<String, dynamic> data =
                            tmp.docs[index - 1].data() as Map<String, dynamic>;
                        return matchSheet(widget.uid, data['chatid'],
                            data['first-name'], data['photo-ref']);
                      },
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: tmp.docs.length + 1)
                  : Center(child: CircularProgressIndicator());
            }));
  }

  Widget matchSheet(String uid, String? chatid, String name, String photoref) {
    print(photoref);
    return FutureBuilder(
        future: DatabaseService(uid: uid).getProfPic(photoref),
        builder: (context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
            // On success
          } else if (snapshot.connectionState == ConnectionState.done) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                          uid: uid,
                          chatid: chatid,
                          name: name,
                          profpic: snapshot.data)),
                );
              },
              // Display match info (user data) on the sheet
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
          } else {
            return Container();
          }
        });
  }
}
