import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/errors.dart';
import 'package:zesti/widgets/loading.dart';

// Widget displaying user cards to make decisions on.
class UserCard extends StatelessWidget {
  final DocumentReference userRef;
  final DocumentReference parentUserRef;
  final bool rec;

  UserCard({
    required this.userRef,
    required this.parentUserRef,
    required this.rec,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    // FutureBuilder used to fetch user photo from Firebase storage.
    return FutureBuilder(
        future: DatabaseService(uid: user!.uid).getUserInfo(userRef),
        builder: (context, AsyncSnapshot<ZestiUser> snapshot) {
          // On error.
          if (snapshot.hasError) {
            return NotFound(
                reason: "This user account has been deleted :(",
                doc: parentUserRef);
          }
          // On success.
          else if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              height: size.height * 0.7,
              width: size.width * 0.95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // User profile pic on card.
                image: DecorationImage(
                  image: snapshot.data!.profPic,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                // Box decoraion and gradient.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                      left: 10,
                      top: 10,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          snapshot.data!.dIntent == "both" ||
                                  snapshot.data!.dIntent == "friendship"
                              ? intentTagTile(
                                  "Friendship", Colors.yellow.shade600)
                              : Container(),
                          snapshot.data!.dIntent == "both" ||
                                  snapshot.data!.dIntent == "love"
                              ? intentTagTile(
                                  "Love", CustomTheme.reallyBrightOrange)
                              : Container(),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => reportDialog(context,
                                    "Report this user?", user.uid, userRef.id));
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.more_horiz,
                              size: 30.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                          )),
                    ),
                    Positioned(
                      right: 10,
                      left: 10,
                      bottom: 10,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: buildUserInfo(snapshot.data!)),
                          // If "rec" is true, we display user cards meant for match recommendations.
                          // Otherwise, the user card is for incoming match requests. They look slightly different
                          // And the buttons call different database functions.
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: InkWell(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.red, size: 64.0),
                              onTap: () async {
                                ZestiLoadingAsync().show(context);
                                if (rec) {
                                  await DatabaseService(uid: user.uid)
                                      .outgoingInteraction(
                                          snapshot.data!.uid, false);
                                } else {
                                  await DatabaseService(uid: user.uid)
                                      .incomingInteraction(
                                          snapshot.data!.uid, false);
                                }
                                ZestiLoadingAsync().dismiss();
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: InkWell(
                              child: Icon(rec ? Icons.send : Icons.check_circle,
                                  color: rec ? Colors.blue : Colors.green,
                                  size: 64.0),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => sendDialog(
                                        context,
                                        rec
                                            ? "Match request sent to " +
                                                snapshot.data!.first +
                                                "!"
                                            : "You matched with " +
                                                snapshot.data!.first +
                                                "!",
                                        user.uid,
                                        snapshot.data!.uid));
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
            return Container(
                height: size.height * 0.7,
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: ZestiLoading());
          }
        });
  }

  // Put user information onto the cards.
  Widget buildUserInfo(ZestiUser userOnCard) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Column displaying user info
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${userOnCard.first}, ${userOnCard.year}',
            style: CustomTheme.textTheme.subtitle1,
          ),
          Text(
            '${userOnCard.house} House',
            style: CustomTheme.textTheme.subtitle2,
          ),
          SizedBox(height: 8),
          Text(
            userOnCard.bio,
            style: CustomTheme.textTheme.subtitle2,
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget sendDialog(
      BuildContext context, String message, String uid, String youid) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(message),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: rec
              ? SvgPicture.asset("assets/phone.svg", semanticsLabel: "Request")
              : SvgPicture.asset("assets/match.svg", semanticsLabel: "Match"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Nice!", style: CustomTheme.textTheme.headline2),
          onPressed: () async {
            ZestiLoadingAsync().show(context);
            if (rec) {
              await DatabaseService(uid: uid).outgoingInteraction(youid, true);
            } else {
              await DatabaseService(uid: uid).incomingInteraction(youid, true);
            }
            ZestiLoadingAsync().dismiss();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// Dummy card class with no decision buttons.
class UserCardDummy extends StatelessWidget {
  final DocumentReference userRef;

  UserCardDummy({
    required this.userRef,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    // FutureBuilder used to fetch user photo from Firebase storage.
    return FutureBuilder(
        future: DatabaseService(uid: user!.uid).getUserInfo(userRef),
        builder: (context, AsyncSnapshot<ZestiUser> snapshot) {
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
                borderRadius: BorderRadius.circular(20),
                // User profile pic on card.
                image: DecorationImage(
                  image: snapshot.data!.profPic,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                // Box decoraion and gradient.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                      left: 10,
                      top: 10,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          snapshot.data!.dIntent == "both" ||
                                  snapshot.data!.dIntent == "friendship"
                              ? intentTagTile(
                                  "Friendship", Colors.yellow.shade600)
                              : Container(),
                          snapshot.data!.dIntent == "both" ||
                                  snapshot.data!.dIntent == "love"
                              ? intentTagTile(
                                  "Love", CustomTheme.reallyBrightOrange)
                              : Container(),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 20,
                      child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => reportDialog(context,
                                    "Report this user?", user.uid, userRef.id));
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.more_horiz,
                              size: 30.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                          )),
                    ),
                    Positioned(
                      right: 10,
                      left: 10,
                      bottom: 10,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: buildUserInfo(snapshot.data!)),
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
            return Container(
                height: size.height * 0.7,
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: ZestiLoading());
          }
        });
  }

  // Put user information onto the cards.
  Widget buildUserInfo(ZestiUser userOnCard) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Column displaying user info
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${userOnCard.first}, ${userOnCard.year}',
              style: CustomTheme.textTheme.subtitle1),
          Text(
            '${userOnCard.house} House',
            style: CustomTheme.textTheme.subtitle2,
          ),
          SizedBox(height: 8),
          Text(
            userOnCard.bio,
            style: CustomTheme.textTheme.subtitle2,
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }
}

class UserOverview extends StatelessWidget {
  final DocumentReference userRef;
  final String name;
  UserOverview({
    Key? key,
    required this.userRef,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: Text(name),
      ),
      body: Container(
          width: size.width,
          height: size.height,
          decoration: CustomTheme.mode,
          padding: EdgeInsets.all(16.0),
          child: UserCardDummy(userRef: userRef)),
    );
  }
}

// Global widget for intent tile indicators.
Widget intentTagTile(String intent, Color color) {
  return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        color: color,
      ),
      padding: EdgeInsets.all(12),
      child: Text(
        intent,
        style: CustomTheme.textTheme.subtitle2,
      ));
}

// Global widget used by both regular and dummy user cards.
Widget reportDialog(
    BuildContext context, String message, String uid, String youid) {
  // Text field controller for reasoning.
  TextEditingController reasonController = TextEditingController();

  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: Text(message),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: double.infinity,
              height: 150.0,
              child: SvgPicture.asset("assets/warning.svg",
                  semanticsLabel: "Report")),
          SizedBox(height: 20.0),
          TextFormField(
            controller: reasonController,
            decoration: InputDecoration(
                hintText: "(Optional) What's wrong?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
          ),
        ],
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text("Cancel", style: CustomTheme.textTheme.headline2),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      TextButton(
        child: Text("Confirm", style: CustomTheme.textTheme.headline1),
        onPressed: () async {
          ZestiLoadingAsync().show(context);
          await DatabaseService(uid: uid).report(
            "user",
            reasonController.text,
            DatabaseService(uid: uid).userCollection.doc(uid),
            DatabaseService(uid: uid).userCollection.doc(youid),
          );
          ZestiLoadingAsync().dismiss();
          Navigator.of(context).pop();
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => reportStatusDialog(context));
        },
      ),
    ],
  );
}

// Global widget used by both regular and dummy user cards.
Widget reportStatusDialog(BuildContext context) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    title: Text("You feedback is under review!"),
    content: SingleChildScrollView(
      child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: SvgPicture.asset("assets/tos.svg",
              semanticsLabel: "Under Review")),
    ),
    actions: <Widget>[
      TextButton(
        child: Text("Ok", style: CustomTheme.textTheme.headline1),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}
