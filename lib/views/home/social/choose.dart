import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zesti/models/zestigroup.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/social/create.dart';
import 'package:zesti/views/home/social/social.dart';
import 'package:zesti/widgets/groupavatar.dart';

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
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: Text("Group Selection"),
      ),
      body: StreamBuilder(
          stream: DatabaseService(uid: user!.uid).getGroups(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            QuerySnapshot? tmp = snapshot.data;
            if (tmp != null) {
              int groupCount = tmp.docs.length;
              return Container(
                  width: size.width,
                  height: size.height,
                  decoration: CustomTheme.mode,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * CustomTheme.paddingMultiplier,
                        horizontal: size.width * CustomTheme.paddingMultiplier),
                    cacheExtent: size.height * 3,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        splashColor: CustomTheme.reallyBrightOrange,
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
                  style: CustomTheme.textTheme.headline3),
            ],
          ),
        ),
      ),
    );
  }

  Widget dummySlot(DocumentReference groupRef, String uid) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        splashColor: CustomTheme.reallyBrightOrange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Social(gid: groupRef.id)),
          );
        },
        child: FutureBuilder(
            future: DatabaseService(uid: uid).getGroupInfo(groupRef),
            builder: (context, AsyncSnapshot<ZestiGroup> snapshot) {
              // On error.
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
                // On success.
              } else if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GroupAvatar(
                          radius: 160.0,
                          groupPhotos: snapshot.data!.groupPhotos),
                      SizedBox(height: 16.0),
                      Text(snapshot.data!.groupName,
                          textAlign: TextAlign.center,
                          style: CustomTheme.textTheme.headline3),
                    ],
                  ),
                );
              } else {
                return Padding(
                    padding: EdgeInsets.all(100.0),
                    child: Center(child: CircularProgressIndicator()));
              }
            }),
      ),
    );
  }
}
