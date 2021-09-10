import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/social/create.dart';
import 'package:zesti/views/home/social/social.dart';

class Choose extends StatefulWidget {
  final String uid;

  Choose({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _ChooseState createState() => _ChooseState();
}

class _ChooseState extends State<Choose> {
  Stream<QuerySnapshot>? groups;
  Stream<DocumentSnapshot>? userInfo;

  @override
  void initState() {
    groups = DatabaseService(uid: widget.uid).getGroups();
    userInfo = DatabaseService(uid: widget.uid).getProfileInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        title: Text("Group Selection"),
      ),
      body: StreamBuilder(
          stream: groups,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            QuerySnapshot? tmp = snapshot.data;
            if (tmp != null) {
              num groupCount = tmp.docs.length;
              return Container(
                  decoration: BoxDecoration(
                    // Box decoration takes a gradient
                    gradient: LinearGradient(
                      // Where the linear gradient begins and ends
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,

                      // Add one stop for each color. Stops should increase from 0 to 1
                      stops: [0.3, 0.9],
                      colors: [
                        // Colors are easy thanks to Flutter's Colors class.
                        CustomTheme.lightTheme.primaryColor,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.0),
                    itemCount: tmp.docs.length + 1,
                    itemBuilder: (context, index) {
                      if (groupCount == 0) {
                        return createGroup();
                      }
                      // Remaining indeces used for matchsheet widgets.
                      Map<String, dynamic> groupData =
                          tmp.docs[index].data() as Map<String, dynamic>;
                      return index == groupCount
                          ? createGroup()
                          : dummySlot("assets/baked-potatoes.jpeg",
                              "The Baked Potatoes");
                    },
                    // A divider widgets is placed in between each matchsheet widget.
                    separatorBuilder: (context, index) => Divider(),
                  ));
            } else {
              return Text("PROFILE INFO RETRIEVAL ERROR");
            }
          }),
    );
  }

  Widget createGroup() {
    String gid = Uuid().v4();
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: CustomTheme.lightTheme.primaryColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Create(gid: gid)),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage("assets/plus.jpg"),
                  backgroundColor: Colors.white),
              SizedBox(height: 16.0),
              Text("Create Group",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[900], fontSize: 24.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget dummySlot(String imagePath, String name) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: CustomTheme.lightTheme.primaryColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Social()),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage(imagePath),
                  backgroundColor: Colors.white),
              SizedBox(height: 16.0),
              Text(name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[900], fontSize: 24.0)),
            ],
          ),
        ),
      ),
    );
  }
}
