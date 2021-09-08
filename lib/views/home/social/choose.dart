import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        title: Text("Group Selection"),
      ),
      body: Container(
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
        child: ListView(children: <Widget>[
          dummySlot(
              "assets/baked-potatoes.jpeg", "Slot 1", "The Baked Potatoes"),
          groupSlot("assets/plus.jpg", "Slot 2", "Create Group"),
          groupSlot("assets/plus.jpg", "Slot 3", "Create Group"),
        ]),
      ),
    );
  }

  Widget groupSlot(String imagePath, String slot, String vendor) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: CustomTheme.lightTheme.primaryColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Create()),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(slot,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[900], fontSize: 24.0)),
              SizedBox(height: 16.0),
              CircleAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage(imagePath),
                  backgroundColor: Colors.white),
              SizedBox(height: 16.0),
              Text(vendor,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[900], fontSize: 24.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget dummySlot(String imagePath, String slot, String vendor) {
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
              Text(slot,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[900], fontSize: 24.0)),
              SizedBox(height: 16.0),
              CircleAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage(imagePath),
                  backgroundColor: Colors.white),
              SizedBox(height: 16.0),
              Text(vendor,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[900], fontSize: 24.0)),
            ],
          ),
        ),
      ),
    );
  }
}
