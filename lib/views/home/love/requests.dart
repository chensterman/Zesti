import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zesti/widgets/usercard.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';

// Displays list of incoming match requests.
class Requests extends StatefulWidget {
  final String uid;
  Requests({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  // Stream for incoming match requests (initialized during initState).
  Stream<QuerySnapshot>? incoming;

  @override
  void initState() {
    incoming = DatabaseService(uid: widget.uid).getIncoming();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      // StreamBuilder to visualize list of incoming match requests.
      child: StreamBuilder(
          stream: incoming,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            QuerySnapshot? tmp = snapshot.data;
            return tmp != null
                ? ListView.separated(
                    // Amount of space to be cached (about 3 user cards in height).
                    //  This stops the FutureBuilder from being super jumpy.
                    cacheExtent: size.height * 0.7 * 3,
                    padding: EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      // First index reserved for text "INCOMING REQUESTS".
                      if (index == 0) {
                        return Center(
                            child: Text('INCOMING REQUESTS',
                                style: TextStyle(color: Colors.orange[900])));
                      }
                      Map<String, dynamic> data =
                          tmp.docs[index - 1].data() as Map<String, dynamic>;
                      return UserCard(userRef: data['user-ref'], rec: false);
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.0),
                    itemCount: tmp.docs.length + 1)
                // While the StreamBuilder is loading, show a progress indicator.
                : Center(child: CircularProgressIndicator());
          }),
    );
  }
}
