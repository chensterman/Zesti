import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/social/create.dart';
import 'package:zesti/views/home/social/social.dart';

class Choose extends StatefulWidget {
  Choose({
    Key? key,
  }) : super(key: key);

  @override
  _ChooseState createState() => _ChooseState();
}

class _ChooseState extends State<Choose> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        title: Text("Group Selection"),
      ),
      body: StreamBuilder(
          stream: DatabaseService(uid: user!.uid).getGroups(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            QuerySnapshot? tmp = snapshot.data;
            if (tmp != null) {
              int groupCount = tmp.docs.length;
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
                    cacheExtent: size.height * 0.7 * 3,
                    itemCount: groupCount + 1,
                    itemBuilder: (context, index) {
                      if (groupCount == 0) {
                        return createGroup();
                      }
                      if (index == groupCount) {
                        return groupCount < 3 ? createGroup() : Container();
                      } else {
                        Map<String, dynamic> groupData =
                            tmp.docs[index].data() as Map<String, dynamic>;
                        return index == groupCount
                            ? createGroup()
                            : dummySlot(groupData['group-ref'], user.uid);
                      }
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
            MaterialPageRoute(builder: (context) => CreateGroup(gid: gid)),
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

  Widget dummySlot(DocumentReference groupRef, String uid) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: CustomTheme.lightTheme.primaryColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Social(gid: groupRef.id)),
          );
        },
        child: FutureBuilder(
            future: DatabaseService(uid: uid).getGroupInfo(groupRef),
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              // On error.
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
                // On success.
              } else if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                          radius: 80.0,
                          backgroundImage:
                              AssetImage("assets/baked-potatoes.jpeg"),
                          backgroundColor: Colors.white),
                      SizedBox(height: 16.0),
                      Text(snapshot.data!['group-name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.orange[900], fontSize: 24.0)),
                    ],
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
