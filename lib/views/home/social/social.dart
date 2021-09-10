import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestigroup.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:zesti/widgets/groupcard.dart';
import 'package:zesti/views/home/social/choose.dart';

// Widget containing swiping, profile management, and matches
class Social extends StatefulWidget {
  final String gid;
  Social({Key? key, required this.gid}) : super(key: key);

  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  // Firebase storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Inital widget to display
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Widget list for bottom nav bar
    final List<Widget> _widgetSet = <Widget>[
      Group(gid: widget.gid),
      Text('Group Recommendations'),
      Text('Incoming Requests'),
      Text('Matches'),
    ];

    // Main page widget (contains nav bar pages as well)
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        title: Text("Zesti Social"),
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
              icon: Icon(Icons.groups), label: "Your Group"),
          BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_top), label: "Group Recommendations"),
          BottomNavigationBarItem(
              icon: Icon(Icons.mood), label: "Incoming Requests"),
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

class Group extends StatefulWidget {
  final String gid;
  Group({
    Key? key,
    required this.gid,
  }) : super(key: key);

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {
  final _formKey = GlobalKey<FormState>();
  String zestKey = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: size.height * 0.1, horizontal: size.width * 0.1),
      child: Form(
        key: _formKey,
        child: Center(
          child: ListView(shrinkWrap: true, children: <Widget>[
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Add a user:",
                      style: CustomTheme.lightTheme.textTheme.headline1,
                    ),
                  ),
                  TextFormField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Please enter a ZestKey.";
                        }
                      },
                      onChanged: (val) {
                        setState(() => zestKey = val);
                      },
                      decoration: const InputDecoration(hintText: "ZestKey")),
                  SizedBox(height: 20.0),
                  RoundedButton(
                      text: 'Add!',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await DatabaseService(uid: user!.uid)
                              .addUserToGroup(widget.gid, zestKey);
                          setState(() => zestKey = '');
                        }
                      }),
                  SizedBox(height: 20.0),
                  RoundedButton(
                      text: 'Leave Group',
                      onPressed: () async {
                        await DatabaseService(uid: user!.uid)
                            .leaveGroup(widget.gid);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Choose()),
                        );
                      }),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

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
                                await DatabaseService(uid: user.uid)
                                    .generateGroupRecommendations(widget.gid);
                              },
                            ),
                          ]),
                        );
                      }

                      // Other indeces used to populate user cards in the ListView.
                      Map<String, dynamic> data =
                          tmp.docs[index - 1].data() as Map<String, dynamic>;
                      ZestiGroup recGroup = ZestiGroup(
                          gid: tmp.docs[index - 1].id,
                          name: data['group-name'],
                          funFact: data['fun-fact']);
                      return GroupCard(
                          gid: widget.gid, groupOnCard: recGroup, rec: true);
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
                      ZestiGroup incGroup = ZestiGroup(
                          gid: tmp.docs[index - 1].id,
                          name: data['group-name'],
                          funFact: data['fun-fact']);
                      return GroupCard(
                          groupOnCard: incGroup,
                          gid: tmp.docs[index - 1].id,
                          rec: false);
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
