import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/deals.dart';
import 'package:zesti/widgets/groupavatar.dart';
import 'package:zesti/widgets/groupcard.dart';
import 'package:zesti/widgets/loading.dart';

// Widget displaying the chat page for a specific match.
class Chat extends StatefulWidget {
  final String uid;
  final String gid;
  final String yougid;
  final DocumentReference chatRef;
  final String groupName;
  final Map<DocumentReference, String> nameMap;
  final Map<DocumentReference, String> yourGroupMap;
  final Map<DocumentReference, ImageProvider<Object>> photoMap;
  final Map<DocumentReference, ImageProvider<Object>> youPhotoMap;
  Chat({
    Key? key,
    required this.uid,
    required this.gid,
    required this.yougid,
    required this.chatRef,
    required this.groupName,
    required this.nameMap,
    required this.yourGroupMap,
    required this.photoMap,
    required this.youPhotoMap,
  }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  // Controls the text parameters for the chat text editor.
  TextEditingController messageText = TextEditingController();
  // Stream to retrieve messages from a specific chat (initialied during initState).
  Stream<QuerySnapshot>? messages;
  DateTime matchTimestamp = DateTime.now();

  @override
  void initState() {
    messages = DatabaseService(uid: widget.uid).getMessages(widget.chatRef);
    super.initState();

    DatabaseService(uid: widget.uid).getChatInfo(widget.chatRef).then((data) {
      setState(() {
        matchTimestamp = data['timestamp'].toDate();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // endDrawer is the restaurant display for discounts.
      endDrawer: Deals(matchTimestamp: matchTimestamp),
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
                        "Unmatch with " + widget.groupName + " forever?",
                        user!.uid,
                        widget.gid,
                        widget.yougid,
                        widget.chatRef.id));
              },
              child: Container(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.cancel,
                  color: Colors.red,
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
              GroupAvatar(
                  groupPhotos: widget.youPhotoMap.values.toList(),
                  radius: 40.0),
              SizedBox(width: 10.0),
              Container(
                  width: size.width * 0.4,
                  child: Text(
                    widget.groupName,
                    style: TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ))
            ],
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GroupUsers(
                        uid: user!.uid,
                        gid: widget.yougid,
                        groupName: widget.groupName)));
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: CustomTheme.cream),
        child: Stack(
          children: [
            chatMessages(user!.uid),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
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
                          textCapitalization: TextCapitalization.sentences,
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
                        // Check for an empty text editor (don't send empty chats).
                        if (messageText.text != '') {
                          sendMessage(user.uid, widget.chatRef, 'text',
                              messageText.text);
                        } else {
                          print('No message content');
                        }
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.orange,
                        size: 48.0,
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
      stream: DatabaseService(uid: uid).getMessages(widget.chatRef),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        QuerySnapshot? tmp = snapshot.data;
        return tmp != null
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 100, top: 16),
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
                                GroupAvatar(
                                    groupPhotos:
                                        widget.youPhotoMap.values.toList(),
                                    radius: 160.0),
                                SizedBox(height: 20.0),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0),
                                  child: Text(
                                    "You matched with " +
                                        widget.groupName +
                                        " on " +
                                        date,
                                    style: CustomTheme.textTheme.headline3,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                              ],
                            );
                          } else {
                            return ZestiLoading();
                          }
                        });
                  }
                  Map<String, dynamic> data =
                      tmp.docs[index].data() as Map<String, dynamic>;
                  if (index == 0 && index + 1 == tmp.docs.length) {
                    return chatMessageTile(data['content'], data['sender-ref'],
                        uid == data['sender-ref'].id, true, true);
                  }
                  if (index == 0) {
                    Map<String, dynamic> dataAbove =
                        tmp.docs[index + 1].data() as Map<String, dynamic>;
                    return chatMessageTile(
                        data['content'],
                        data['sender-ref'],
                        uid == data['sender-ref'].id,
                        true,
                        data['sender-ref'].id != dataAbove['sender-ref'].id);
                  } else if (index + 1 == tmp.docs.length) {
                    Map<String, dynamic> dataBelow =
                        tmp.docs[index - 1].data() as Map<String, dynamic>;
                    return chatMessageTile(
                        data['content'],
                        data['sender-ref'],
                        uid == data['sender-ref'].id,
                        data['sender-ref'].id != dataBelow['sender-ref'].id,
                        true);
                  } else {
                    Map<String, dynamic> dataBelow =
                        tmp.docs[index - 1].data() as Map<String, dynamic>;
                    Map<String, dynamic> dataAbove =
                        tmp.docs[index + 1].data() as Map<String, dynamic>;
                    return chatMessageTile(
                        data['content'],
                        data['sender-ref'],
                        uid == data['sender-ref'].id,
                        data['sender-ref'].id != dataBelow['sender-ref'].id,
                        data['sender-ref'].id != dataAbove['sender-ref'].id);
                  }
                })
            : ZestiLoading();
      },
    );
  }

  // Widget for a message tile.
  //  Parameters include message content and a boolean for if it was sent by the current user.
  Widget chatMessageTile(String message, DocumentReference senderRef,
      bool sendByMe, bool bottomChain, bool topChain) {
    Color? bubbleColor;
    if (sendByMe) {
      bubbleColor = Colors.orange;
    } else if (widget.yourGroupMap[senderRef] != null) {
      bubbleColor = Colors.yellow[700];
    } else {
      bubbleColor = Colors.grey[350];
    }
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        bottomChain && !sendByMe
            ? Padding(
                child: CircleAvatar(
                    radius: 20.0,
                    backgroundImage: widget.photoMap[senderRef] == null
                        ? AssetImage("assets/profile.jpg")
                        : widget.photoMap[senderRef],
                    backgroundColor: Colors.white),
                padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
              )
            : Padding(
                child: SizedBox(height: 40.0, width: 40.0),
                padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
              ),
        widget.nameMap[senderRef] != null
            ? Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      topChain && !sendByMe
                          ? Padding(
                              child: Text(widget.nameMap[senderRef]!),
                              padding: EdgeInsets.only(left: 20.0, top: 16.0),
                            )
                          : SizedBox.shrink(),
                      Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomRight: sendByMe
                                  ? Radius.circular(0)
                                  : Radius.circular(24),
                              topRight: Radius.circular(24),
                              bottomLeft: sendByMe
                                  ? Radius.circular(24)
                                  : Radius.circular(0),
                            ),
                            color: bubbleColor,
                          ),
                          padding: EdgeInsets.all(16),
                          child: Text(
                            message,
                            style: TextStyle(color: Colors.white),
                          )),
                    ]),
              )
            : Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      topChain && !sendByMe
                          ? Padding(
                              child: Text("USER HAS LEFT"),
                              padding: EdgeInsets.only(left: 20.0, top: 16.0),
                            )
                          : SizedBox.shrink(),
                      Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomRight: sendByMe
                                  ? Radius.circular(0)
                                  : Radius.circular(24),
                              topRight: Radius.circular(24),
                              bottomLeft: sendByMe
                                  ? Radius.circular(24)
                                  : Radius.circular(0),
                            ),
                            color: bubbleColor,
                          ),
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "(EXPIRED MESSAGE)",
                            style: TextStyle(color: Colors.white),
                          )),
                    ]),
              )
      ],
    );
  }

  // Call database service to send message.
  sendMessage(
      String uid, DocumentReference chatRef, String type, String content) {
    DatabaseService(uid: uid).sendMessage(chatRef, "", type, content);
    // Reset the text editor controller after message is sent.
    messageText.text = '';
  }

  Widget unmatchDialog(BuildContext context, String message, String uid,
      String gid, String yougid, String chatid) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
          child: Text("Yes", style: CustomTheme.textTheme.headline1),
          onPressed: () async {
            // Unmatch from database
            ZestiLoadingAsync().show(context);
            await DatabaseService(uid: uid).unmatchGroup(gid, yougid, chatid);
            ZestiLoadingAsync().dismiss();

            // Pop pages
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
