import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/deals.dart';
import 'package:zesti/widgets/usercard.dart';

// Widget displaying the chat page for a specific match.
class Chat extends StatefulWidget {
  final String uid;
  final String youid;
  final DocumentReference chatRef;
  final String name;
  final ImageProvider<Object> profpic;
  Chat({
    Key? key,
    required this.uid,
    required this.youid,
    required this.chatRef,
    required this.name,
    required this.profpic,
  }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // Controls the text parameters for the chat text editor.
  TextEditingController messageText = TextEditingController();
  // Stream to retrieve messages from a specific chat (initialied during initState).
  Stream<QuerySnapshot>? messages;

  @override
  void initState() {
    messages = DatabaseService(uid: widget.uid).getMessages(widget.chatRef);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // endDrawer is the restaurant display for discounts.
      endDrawer: Deals(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomTheme.reallyBrightOrange,
        elevation: 0.0,
        actions: [
          InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => unmatchDialog(
                        context,
                        "Unmatch with " + widget.name + " forever?",
                        user!.uid,
                        widget.youid,
                        widget.chatRef.id));
              },
              child: Container(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.cancel,
                  color: Colors.redAccent[700],
                  size: 26.0,
                ),
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              )),
          SizedBox(width: 20.0),
          Builder(
            builder: (context) => InkWell(
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.fastfood_rounded,
                    color: CustomTheme.reallyBrightOrange,
                    size: 22.0,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                )),
          ),
          SizedBox(width: 20.0),
        ],
        title: InkWell(
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundImage: widget.profpic,
                backgroundColor: Colors.white,
              ),
              SizedBox(width: 10.0),
              Text(widget.name, style: TextStyle(fontSize: 20)),
            ],
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserOverview(
                        userRef: DatabaseService(uid: user!.uid)
                            .userCollection
                            .doc(widget.youid),
                        name: widget.name)));
          },
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
                        if (messageText.text != '') {
                          sendMessage(user!.uid, widget.chatRef, 'text',
                              messageText.text);
                        }
                      },
                      child: Icon(
                        Icons.send,
                        color: CustomTheme.reallyBrightOrange,
                        size: 32.0,
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

  // Display all chat messages for the match.
  Widget chatMessages(String uid) {
    // StreamBuilder to display messages stream.
    return StreamBuilder(
      stream: messages,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        QuerySnapshot? tmp = snapshot.data;
        return tmp != null
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 90, top: 16),
                itemCount: tmp.docs.length + 1,
                reverse: true,
                itemBuilder: (context, index) {
                  if (index == tmp.docs.length) {
                    return FutureBuilder(
                        future: DatabaseService(uid: uid)
                            .getChatInfo(widget.chatRef),
                        builder: (context,
                            AsyncSnapshot<Map<String, dynamic>> snapshot) {
                          // On error.
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          // On success.
                          else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            DateTime ts = snapshot.data!['timestamp'].toDate();
                            String date = ts.month.toString() +
                                "/" +
                                ts.day.toString() +
                                "/" +
                                ts.year.toString();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                    radius: 80.0,
                                    backgroundImage: widget.profpic,
                                    backgroundColor: Colors.white),
                                SizedBox(height: 20.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0),
                                  child: Text(
                                    "You matched with " +
                                        widget.name +
                                        " on " +
                                        date,
                                    style: CustomTheme.textTheme.headline3,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 50.0),
                              ],
                            );
                          } else {
                            return CustomTheme.loading;
                          }
                        });
                  }
                  Map<String, dynamic> data =
                      tmp.docs[index].data() as Map<String, dynamic>;
                  if (index == 0 && index + 1 == tmp.docs.length) {
                    return chatMessageTile(data['content'],
                        uid == data['sender-ref'].id, true, true);
                  }
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
            : Center(child: CustomTheme.loading);
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
