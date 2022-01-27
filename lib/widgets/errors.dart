// Dart file container various error widgets used across the app.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/loading.dart';

// Text input used across multiple forms.
class Empty extends StatelessWidget {
  final String reason;
  Empty({
    Key? key,
    required this.reason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(top: 24.0, right: 8.0, left: 8.0, bottom: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(reason,
                textAlign: TextAlign.left,
                style: CustomTheme.textTheme.headline2),
            SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              height: size.height * 0.3,
              child:
                  SvgPicture.asset("assets/empty.svg", semanticsLabel: "Name"),
            ),
          ],
        ),
      ),
    );
  }
}

// Rounded looking button used across multiple forms.
class NotFound extends StatelessWidget {
  final String reason;
  final DocumentReference doc;
  NotFound({
    Key? key,
    required this.reason,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0, bottom: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(reason,
                textAlign: TextAlign.center,
                style: CustomTheme.textTheme.headline2),
            SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              height: size.height * 0.3,
              child: SvgPicture.asset("assets/notfound.svg",
                  semanticsLabel: "Name"),
            ),
            InkWell(
              child: Icon(Icons.cancel_rounded, color: Colors.red, size: 64.0),
              onTap: () async {
                ZestiLoadingAsync().show(context);
                await doc.delete();
                ZestiLoadingAsync().dismiss();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Rounded looking button used across multiple forms.
class NotFoundMatchSheet extends StatelessWidget {
  final DocumentReference doc;
  NotFoundMatchSheet({
    Key? key,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () async {
          ZestiLoadingAsync().show(context);
          await doc.delete();
          ZestiLoadingAsync().dismiss();
        },
        // Display match info (user data) on the sheet.
        child: Container(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 160.0,
                  height: 16.0,
                  child: SvgPicture.asset("assets/name.svg",
                      semanticsLabel: "Name"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("This group disbanded :(",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(height: 10.0),
                    Text('Sorry... tap to remove',
                        style: TextStyle(fontSize: 16))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
