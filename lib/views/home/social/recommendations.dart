import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/widgets/errors.dart';
import 'package:zesti/widgets/groupcard.dart';
import 'package:zesti/theme/theme.dart';

// Displays list of recommended matches.
class Recommendations extends StatefulWidget {
  final String gid;
  Recommendations({
    Key? key,
    required this.gid,
  }) : super(key: key);

  @override
  _RecommendationsState createState() => _RecommendationsState();
}

class _RecommendationsState extends State<Recommendations> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    return Container(
      // Streambuilder for recommendations stream.
      child: StreamBuilder(
          stream: DatabaseService(uid: user!.uid)
              .getGroupRecommendations(widget.gid),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            QuerySnapshot? tmp = snapshot.data;
            return tmp != null
                // ListView to visualize list of recommendations.
                ? ListView.separated(
                    // Amount of space to be cached (about 3 user cards in height).
                    //  This stops the FutureBuilder from being super jumpy.
                    cacheExtent: size.height * 0.7 * 3,
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * CustomTheme.paddingMultiplier,
                        horizontal: size.width * CustomTheme.paddingMultiplier),
                    itemBuilder: (context, index) {
                      // First index reserved for text "RECOMMENDATIONS".
                      if (index == 0) {
                        return Center(
                          child: Column(children: [
                            Container(
                              margin: EdgeInsets.only(left: 10.0),
                              width: double.infinity,
                              child: Text('Recommendations',
                                  textAlign: TextAlign.left,
                                  style: CustomTheme.textTheme.headline3),
                            ),
                            TextButton(
                              child: Text('Generate'),
                              onPressed: () async {
                                await DatabaseService(uid: user.uid)
                                    .generateGroupRecommendations(widget.gid);
                              },
                            ),
                            tmp.docs.length == 0
                                ? Empty(
                                    reason:
                                        "You've ran out of recommendations for the week! Make sure your group has more than one member!")
                                : Container(),
                          ]),
                        );
                      }

                      // Other indeces used to populate user cards in the ListView.
                      Map<String, dynamic> data =
                          tmp.docs[index - 1].data() as Map<String, dynamic>;
                      return GroupCard(
                          gid: widget.gid,
                          groupRef: data['group-ref'],
                          parentGroupRef: tmp.docs[index - 1].reference,
                          rec: true);
                    },
                    // SizedBox used as separated between user cards.
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.0),
                    itemCount: tmp.docs.length + 1)
                // When StreamBuilder hasn't loaded, show progress indicator.
                : Center(child: CustomTheme.loading);
          }),
    );
  }
}
