import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zesti/views/home/chat.dart';

class MatchSheet extends StatelessWidget {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String name;
  final String imgUrl;
  MatchSheet({
    Key? key,
    this.name = 'NULL',
    this.imgUrl = 'NULL',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FutureBuilder(
              future: _storage.ref().child(imgUrl).getData(),
              builder: (context, AsyncSnapshot<Uint8List?> snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Error'),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  Uint8List? data = snapshot.data;
                  if (data == null) {
                    return Text('Error');
                  } else {
                    MemoryImage imgNull = MemoryImage(data);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Chat(name: name, imgNull: imgNull)),
                        );
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CircleAvatar(
                                radius: 40.0,
                                backgroundImage: imgNull,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20)),
                                  SizedBox(height: 10.0),
                                  Text('Hi there!',
                                      style: TextStyle(fontSize: 16))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
                // Otherwise, return a loading screen
                else {
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()));
                }
              }),
        ),
      ],
    );
  }
}
