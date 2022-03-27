import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zesti/widgets/errors.dart';
import 'package:zesti/widgets/loading.dart';
import 'package:zesti/widgets/usercard.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/services/database.dart';

// Displays list of recommended matches.
class Recommendations extends StatefulWidget {
  final String uid;
  Recommendations({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _RecommendationsState createState() => _RecommendationsState();
}

class _RecommendationsState extends State<Recommendations> {
  // Stream of current recommendations (initialized in initState).
  Stream<QuerySnapshot>? recommendations;

  @override
  void initState() {
    recommendations = DatabaseService(uid: widget.uid).getRecommendations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      // Streambuilder for recommendations stream.
      child: StreamBuilder(
          stream: recommendations,
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
                            tmp.docs.length == 0
                                ? Empty(
                                    reason:
                                        "Check back in a few hours for new recs!")
                                : Container(),
                          ]),
                        );
                      }

                      // Other indeces used to populate user cards in the ListView.
                      Map<String, dynamic> data =
                          tmp.docs[index - 1].data() as Map<String, dynamic>;
                      return UserCard(
                          userRef: data['user-ref'],
                          parentUserRef: tmp.docs[index - 1].reference,
                          rec: true);
                    },
                    // SizedBox used as separated between user cards.
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.0),
                    itemCount: tmp.docs.length + 1)
                // When StreamBuilder hasn't loaded, show progress indicator.
                : ZestiLoading();
          }),
    );
  }
}
