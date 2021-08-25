import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';

// Widget displaying the chat page for a specific match
class Chat extends StatefulWidget {
  final String uid;
  final String? chatid;
  final String name;
  final ImageProvider<Object>? profpic;
  Chat({
    Key? key,
    required this.uid,
    required this.chatid,
    required this.name,
    required this.profpic,
  }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController messageText = TextEditingController();
  Stream<QuerySnapshot>? messages;

  @override
  void initState() {
    messages = DatabaseService(uid: widget.uid).getMessages(widget.chatid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return Scaffold(
      // endDrawer is the restaurant display for discounts
      endDrawer: Drawer(
        child: Container(
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
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.orange.shade900,
                ),
                child: Center(
                  child: Text(
                    'Deals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
              dealCard("assets/spyce.jpg", "SPYCE",
                  "20% off of the Spring and Summer menu!"),
              dealCard("assets/zinnekens.jpg", "ZINNEKEN'S",
                  "20% off of any purchase!"),
              dealCard("assets/maharaja.jpg", "THE MAHARAJA",
                  "Anything off of the dessert menu, on the house!"),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {},
            color: Colors.red,
          ),
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
              backgroundImage: widget.profpic,
              backgroundColor: Colors.white,
            ),
            SizedBox(width: 10.0),
            Text(widget.name, style: TextStyle(fontSize: 20))
          ],
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(widget.uid),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white.withOpacity(0.8),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey, // set border color
                              width: 1.0), // set border width
                          borderRadius: BorderRadius.all(Radius.circular(
                              29.0)), // set rounded corner radius
                        ),
                        child: TextField(
                          controller: messageText,
                          style: TextStyle(color: Colors.grey),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Aa",
                              hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.6))),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (user == null) {
                          print('User Error');
                        } else {
                          if (messageText.text != '') {
                            sendMessage(user.uid, widget.chatid, 'text',
                                messageText.text);
                          } else {
                            print('No message content');
                          }
                        }
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.orange,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget dealCard(String imagePath, String vendor, String description) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: CustomTheme.lightTheme.primaryColor,
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage(imagePath),
                  backgroundColor: Colors.white),
              SizedBox(height: 16.0),
              Text(vendor,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[900], fontSize: 24.0)),
              Text(description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget chatMessages(String uid) {
    return StreamBuilder(
      stream: messages,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        QuerySnapshot? tmp = snapshot.data;
        return tmp != null
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 90, top: 16),
                itemCount: snapshot.data?.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data =
                      tmp.docs[index].data() as Map<String, dynamic>;
                  return chatMessageTile(
                      data['content'], uid == data['sender']);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sendByMe ? Radius.circular(24) : Radius.circular(0),
                ),
                color: sendByMe ? Colors.orange : Colors.grey[350],
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
  }

  sendMessage(String uid, String? chatid, String type, String content) {
    DatabaseService(uid: uid).sendMessage(chatid, type, content);
    messageText.text = '';
  }
}
