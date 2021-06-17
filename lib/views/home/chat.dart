import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';

class Chat extends StatefulWidget {
  final String name;
  final MemoryImage? imgNull;
  Chat({
    Key? key,
    this.name = 'NULL',
    this.imgNull,
  }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  dynamic imageFile = AssetImage('assets/profile.jpg');
  @override
  void initState() {
    super.initState();
    if (widget.imgNull != null) {
      imageFile = widget.imgNull;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      endDrawer: Drawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        elevation: 0.0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.fastfood),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              color: Colors.white,
            ),
          ),
        ],
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: imageFile,
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 10.0),
            Text(widget.name, style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }
}
