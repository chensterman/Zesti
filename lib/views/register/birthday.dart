import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/views/register/identity.dart';

class NumberLine extends StatelessWidget {
  NumberLine({@required this.width, @required this.text});
  final width;
  final text;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        padding: const EdgeInsets.only(bottom: 8),
        child: Center(
            child: Text("$text",
                style: CustomTheme.lightTheme.textTheme.headline2)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: CustomTheme.lightTheme.accentColor, width: 2.0))));
  }
}

class Birthday extends StatefulWidget {
  @override
  _BirthdayState createState() => _BirthdayState();
}

class _BirthdayState extends State<Birthday> {
  DateTime birthday = DateTime.now();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
            width: size.width * CustomTheme.containerWidth,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "What's your date of birth?",
                    style: CustomTheme.lightTheme.textTheme.headline1,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NumberLine(width: size.width * .15, text: "10"),
                      Text("/", style: TextStyle(fontSize: 25)),
                      NumberLine(width: size.width * .15, text: "25"),
                      Text("/", style: TextStyle(fontSize: 25)),
                      NumberLine(width: size.width * .2, text: "2000"),
                    ],
                  )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: size.width * CustomTheme.containerWidth * 0.42,
                      child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: CustomTheme.lightTheme.primaryColor,
                                padding: const EdgeInsets.only(
                                    left: 30, top: 10, right: 30, bottom: 10),
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0))),
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(1900, 3, 5),
                                  maxTime: DateTime(2021, 6, 7),
                                  onChanged: (date) {
                                print('change $date in time zone ' +
                                    date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm $date');
                                birthday = date;
                                print(birthday);
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            child: Text("Select"),
                          )),
                    ),
                    SizedBox(
                      width: size.width * CustomTheme.containerWidth * 0.42,
                      child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: CustomTheme.lightTheme.primaryColor,
                                padding: const EdgeInsets.only(
                                    left: 30, top: 10, right: 30, bottom: 10),
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0))),
                            onPressed: () async {
                              if (user == null) {
                                print("Error");
                              } else {
                                await DatabaseService(uid: user.uid)
                                    .updateBirthday(
                                        Timestamp.fromDate(birthday));
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Identity()),
                              );
                            },
                            child: Text("Confirm"),
                          )),
                    )
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.3,
                  child: SvgPicture.asset("assets/birthday.svg",
                      semanticsLabel: "Name"),
                )
              ],
            )),
      ),
    );
  }
}
