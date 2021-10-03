import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/redeem.dart';
import 'package:zesti/widgets/groupavatar.dart';

// Widget displaying the chat page for a specific match.
class Chat extends StatefulWidget {
  final String gid;
  final String yougid;
  final DocumentReference chatRef;
  final String groupName;
  final Map<DocumentReference, String> nameMap;
  final Map<DocumentReference, ImageProvider<Object>> photoMap;
  Chat({
    Key? key,
    required this.gid,
    required this.yougid,
    required this.chatRef,
    required this.groupName,
    required this.nameMap,
    required this.photoMap,
  }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // Controls the text parameters for the chat text editor.
  TextEditingController messageText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return Scaffold(
      // endDrawer is the restaurant display for discounts.
      endDrawer: Drawer(
        child: Container(
          decoration: CustomTheme.standard,
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
              dealCard("assets/amorino.jpg", "AMORINO",
                  "20% off of the Spring and Summer menu!"),
              dealCard("assets/grendels.jpg", "GRENDEL'S DEN",
                  "Free \$20 gift card for each visit (max 3)!"),
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
        backgroundColor: CustomTheme.reallyBrightOrange,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => unmatchDialog(
                      context,
                      "Unmatch with " + widget.groupName + " forever?",
                      user!.uid,
                      widget.groupName,
                      widget.chatRef.id));
            },
            color: Colors.orange[300],
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
            GroupAvatar(
                groupPhotos: widget.photoMap.values.toList(), radius: 80.0),
            SizedBox(width: 10.0),
            Text(widget.groupName, style: TextStyle(fontSize: 20))
          ],
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(user!.uid),
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
                          // Check for an empty text editor (don't send empty chats).
                          if (messageText.text != '') {
                            sendMessage(user.uid, widget.chatRef, 'text',
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

  // Card that displays a specific partner deal.
  Widget dealCard(String imagePath, String vendor, String description) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: CustomTheme.reallyBrightOrange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Redeem(
                    imagePath: imagePath,
                    vendor: vendor,
                    description: description)),
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

  // Display all chat messages for the match.
  Widget chatMessages(String uid) {
    // StreamBuilder to display messages stream.
    return StreamBuilder(
      stream: DatabaseService(uid: uid).getMessages(widget.chatRef),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        QuerySnapshot? tmp = snapshot.data;
        return tmp != null
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 90, top: 16),
                itemCount: tmp.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data =
                      tmp.docs[index].data() as Map<String, dynamic>;
                  if (index == 0) {
                    return chatMessageTile(data['content'],
                        uid == data['sender-ref'].id, true, false);
                  } else if (index + 1 == tmp.docs.length) {
                    return chatMessageTile(data['content'],
                        uid == data['sender-ref'].id, false, true);
                  } else {
                    Map<String, dynamic> dataAbove =
                        tmp.docs[index - 1].data() as Map<String, dynamic>;
                    Map<String, dynamic> dataBelow =
                        tmp.docs[index + 1].data() as Map<String, dynamic>;
                    return chatMessageTile(
                        data['content'],
                        uid == data['sender-ref'].id,
                        uid == dataAbove['sender-ref'].id,
                        uid == dataBelow['sender-ref'].id);
                  }
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  // Widget for a message tile.
  //  Parameters include message content and a boolean for if it was sent by the current user.
  Widget chatMessageTile(
      String message, bool sendByMe, bool bottomChain, bool topChain) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        bottomChain && !sendByMe
            ? Padding(
                child: CircleAvatar(
                    radius: 20.0,
                    backgroundImage: widget.profpic,
                    backgroundColor: Colors.white),
                padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
              )
            : Padding(
                child: SizedBox(height: 40.0, width: 40.0),
                padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
              ),
        Flexible(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            topChain && !sendByMe
                ? Padding(
                    child: Text(widget.name),
                    padding:
                        EdgeInsets.only(left: 20.0, top: 16.0, bottom: 8.0),
                  )
                : SizedBox.shrink(),
            Container(
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
          ]),
        ),
      ],
    );
  }

  // Call database service to send message.
  sendMessage(
      String uid, DocumentReference chatRef, String type, String content) {
    DatabaseService(uid: uid).sendMessage(chatRef, type, content);
    // Reset the text editor controller after message is sent.
    messageText.text = '';
  }

  Widget unmatchDialog(BuildContext context, String message, String uid,
      String youid, String chatid) {
    return AlertDialog(
      title: Text(message),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child:
              SvgPicture.asset("assets/warning.svg", semanticsLabel: "Warning"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Yes", style: CustomTheme.textTheme.headline2),
          onPressed: () async {
            await DatabaseService(uid: uid).unmatch(youid, chatid);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("No", style: CustomTheme.textTheme.headline2),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
