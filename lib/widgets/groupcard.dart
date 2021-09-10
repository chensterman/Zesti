import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestigroup.dart';
import 'package:zesti/services/database.dart';

// Widget displaying user cards to make decisions on.
class GroupCard extends StatelessWidget {
  final String gid;
  final ZestiGroup groupOnCard;
  final bool rec;

  GroupCard({
    required this.gid,
    required this.groupOnCard,
    required this.rec,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    // FutureBuilder used to fetch user photo from Firebase storage.
    return FutureBuilder(
        future: DatabaseService(uid: user!.uid).getPhoto(null),
        builder: (context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
          // On error.
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          // On success.
          else if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              height: size.height * 0.7,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                // User profile pic on card.
                image: DecorationImage(
                  image: snapshot.data!,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                // Box decoraion and gradient.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
                  ],
                  gradient: LinearGradient(
                    colors: [Colors.black12, Colors.black87],
                    begin: Alignment.center,
                    stops: [0.4, 1],
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 10,
                      left: 10,
                      bottom: 10,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildGroupInfo(group: groupOnCard),
                          // If "rec" is true, we display user cards meant for match recommendations.
                          // Otherwise, the user card is for incoming match requests. They look slightly different
                          // And the buttons call different database functions.
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: InkWell(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.red, size: 64.0),
                              onTap: () async {
                                if (rec) {
                                  await DatabaseService(uid: user.uid)
                                      .outgoingGroupInteraction(
                                          gid, groupOnCard.gid, false);
                                } else {
                                  await DatabaseService(uid: user.uid)
                                      .incomingGroupInteraction(
                                          gid, groupOnCard.gid, false);
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: InkWell(
                              child: Icon(rec ? Icons.send : Icons.check_circle,
                                  color: rec ? Colors.blue : Colors.green,
                                  size: 64.0),
                              onTap: () async {
                                if (rec) {
                                  await DatabaseService(uid: user.uid)
                                      .outgoingGroupInteraction(
                                          gid, groupOnCard.gid, true);
                                } else {
                                  await DatabaseService(uid: user.uid)
                                      .incomingGroupInteraction(
                                          gid, groupOnCard.gid, true);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // On loading, return an empty container.
          else {
            return Container();
          }
        });
  }

  // Put user information onto the cards.
  Widget buildGroupInfo({@required final group}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Column displaying user info
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${group.name}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            group.funFact,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            '',
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}

// Dummy card class with empty fields.
class UserCardDummy extends StatelessWidget {
  final bool rec;

  UserCardDummy({
    required this.rec,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.7,
      width: size.width * 0.95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // User profile pic on card.
        image: DecorationImage(
          image: AssetImage("assets/profile.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black12, spreadRadius: 0.5),
          ],
          gradient: LinearGradient(
            colors: [Colors.black12, Colors.black87],
            begin: Alignment.center,
            stops: [0.4, 1],
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 10,
              left: 10,
              bottom: 10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildUserInfo(),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: InkWell(
                      child: Icon(Icons.cancel_rounded,
                          color: Colors.red, size: 64.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: InkWell(
                      child: Icon(rec ? Icons.send : Icons.check_circle,
                          color: rec ? Colors.blue : Colors.green, size: 64.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Column displaying user info
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            "",
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}
