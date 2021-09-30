import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestiuser.dart';

// Widget displaying user cards to make decisions on.
class PreviewCard extends StatelessWidget {
  final ZestiUser userOnCard;
  final bool rec;
  final String? id;

  PreviewCard({
    required this.userOnCard,
    required this.rec,
    this.id,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.7,
      width: size.width * 0.95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // User profile pic on card.
        image: DecorationImage(
          image: userOnCard.profPic,
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
                  buildUserInfo(user: userOnCard),
                  // If "rec" is true, we display user cards meant for match recommendations.
                  // Otherwise, the user card is for incoming match requests. They look slightly different
                  // And the buttons call different database functions.
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: InkWell(
                      child: Icon(Icons.cancel_rounded,
                          color: Colors.red, size: 64.0),
                      onTap: () {},
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: InkWell(
                      child: Icon(rec ? Icons.send : Icons.check_circle,
                          color: rec ? Colors.blue : Colors.green, size: 64.0),
                      onTap: () {},
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

  // Put user information onto the cards.
  Widget buildUserInfo({@required final user}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // Column displaying user info
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${user.first}, ${user.age}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            user.bio,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            '${user.house} House',
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}
