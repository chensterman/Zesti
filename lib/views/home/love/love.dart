import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/love/matches.dart';
import 'package:zesti/widgets/usercard.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';

// Widget containing swiping, profile management, and matches.
class Love extends StatefulWidget {
  Love({Key? key}) : super(key: key);

  @override
  _LoveState createState() => _LoveState();
}

class _LoveState extends State<Love> {
  // Inital widget to display.
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    Size size = MediaQuery.of(context).size;
    // Widget list for bottom nav bar.
    final List<Widget> _widgetSet = <Widget>[
      Recommendations(uid: user!.uid),
      Requests(uid: user.uid),
      Matches(uid: user.uid),
    ];

    // Main page widget (contains nav bar pages as well).
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        title: Text("Zesti Love"),
      ),
      body: Center(
        child: _widgetSet.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: size.width * 0.08,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_top), label: "Match Recommendations"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Match Requests"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble), label: "Matches"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: CustomTheme.lightTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  // Change selected index for onTap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

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
                    padding: EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      // First index reserved for text "RECOMMENDATIONS".
                      if (index == 0) {
                        return Center(
                          child: Column(children: [
                            Text('RECOMMENDATIONS',
                                style: TextStyle(color: Colors.orange[900])),
                            TextButton(
                              child: Text('Generate'),
                              onPressed: () async {
                                await DatabaseService(uid: widget.uid)
                                    .generateRecommendations();
                              },
                            ),
                          ]),
                        );
                      }

                      // Other indeces used to populate user cards in the ListView.
                      Map<String, dynamic> data =
                          tmp.docs[index - 1].data() as Map<String, dynamic>;
                      // FutureBuilder used to fetch user photo from Firebase storage.
                      return FutureBuilder(
                          future: DatabaseService(uid: widget.uid)
                              .getProfPic(data['photo-ref']),
                          builder: (context,
                              AsyncSnapshot<ImageProvider<Object>> snapshot) {
                            // On error.
                            if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                              // On success.
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              ZestiUser incUser = ZestiUser(
                                  uid: data['user-ref'].id,
                                  first: data['first-name'],
                                  last: data['last-name'],
                                  bio: data['bio'],
                                  dIdentity: data['dating-identity'],
                                  dInterest: data['dating-interest'],
                                  house: data['house'],
                                  age: data['age'],
                                  profpic: snapshot.data!);
                              return UserCard(userOnCard: incUser, rec: true);
                              // On loading, return an empty container.
                            } else {
                              return Container();
                            }
                          });
                    },
                    // SizedBox used as separated between user cards.
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.0),
                    itemCount: tmp.docs.length + 1)
                // When StreamBuilder hasn't loaded, show progress indicator.
                : Center(child: CircularProgressIndicator());
          }),
    );
  }
}

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
                      // FutureBuilder used to load user profile photo from Firebase Storage.
                      return FutureBuilder(
                          future: DatabaseService(uid: widget.uid)
                              .getProfPic(data['photo-ref']),
                          builder: (context,
                              AsyncSnapshot<ImageProvider<Object>> snapshot) {
                            // On error.
                            if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                              // On success.
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              ZestiUser incUser = ZestiUser(
                                  uid: data['user-ref'].id,
                                  first: data['first-name'],
                                  last: data['last-name'],
                                  bio: data['bio'],
                                  dIdentity: data['dating-identity'],
                                  dInterest: data['dating-interest'],
                                  house: data['house'],
                                  age: data['age'],
                                  profpic: snapshot.data!);
                              return UserCard(
                                  userOnCard: incUser,
                                  id: tmp.docs[index - 1].id,
                                  rec: false);
                              // On loading, return an empty container.
                            } else {
                              return Container();
                            }
                          });
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
