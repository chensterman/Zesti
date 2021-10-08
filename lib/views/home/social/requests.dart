import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/widgets/errors.dart';
import 'package:zesti/widgets/groupcard.dart';
import 'package:zesti/theme/theme.dart';

// Displays list of incoming match requests.
class Requests extends StatefulWidget {
  final String gid;
  Requests({
    Key? key,
    required this.gid,
  }) : super(key: key);

  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  // Stream for incoming match requests (initialized during initState).
  Stream<QuerySnapshot>? incoming;

  @override
  void initState() {
    incoming = DatabaseService(uid: widget.gid).getGroupIncoming(widget.gid);
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
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * CustomTheme.paddingMultiplier,
                        horizontal: size.width * CustomTheme.paddingMultiplier),
                    itemBuilder: (context, index) {
                      // First index reserved for text "INCOMING REQUESTS".
                      if (index == 0) {
                        return Column(children: [
                          Container(
                            margin: EdgeInsets.only(left: 10.0),
                            width: double.infinity,
                            child: Text('Incoming Requests',
                                textAlign: TextAlign.left,
                                style: CustomTheme.textTheme.headline3),
                          ),
                          tmp.docs.length == 0
                              ? Empty(
                                  reason:
                                      "No incoming requests  at the moment, but maybe later!")
                              : Container(),
                        ]);
                      }
                      Map<String, dynamic> data =
                          tmp.docs[index - 1].data() as Map<String, dynamic>;
                      return GroupCard(
                          gid: widget.gid,
                          groupRef: data['group-ref'],
                          parentGroupRef: tmp.docs[index - 1].reference,
                          rec: false);
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.0),
                    itemCount: tmp.docs.length + 1)
                // While the StreamBuilder is loading, show a progress indicator.
                : Center(child: CustomTheme.loading);
          }),
    );
  }
}
