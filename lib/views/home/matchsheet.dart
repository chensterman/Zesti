import 'package:flutter/material.dart';
import 'package:zesti/views/home/chat.dart';

// Widget for individual match to display in listview
class MatchSheet extends StatelessWidget {
  final String name;
  final ImageProvider<Object> profpic;
  MatchSheet({
    Key? key,
    required this.name,
    required this.profpic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // When sheet is tapped, navigates to chat with the match
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chat(name: name, profpic: profpic)),
        );
      },
      // Display match info (user data) on the sheet
      child: Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircleAvatar(
                radius: 40.0,
                backgroundImage: profpic,
                backgroundColor: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 10.0),
                  Text('Hi there!', style: TextStyle(fontSize: 16))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
