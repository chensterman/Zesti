import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/views/register/name.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:zesti/widgets/loading.dart';

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
            child: Text("$text", style: CustomTheme.textTheme.headline2)),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: CustomTheme.transitioningOrange, width: 2.0))));
  }
}

// Widget for the birthday form
class Birthday extends StatefulWidget {
  @override
  _BirthdayState createState() => _BirthdayState();
}

class _BirthdayState extends State<Birthday> {
  DateTime birthday = DateTime.now();
  dynamic month = "--";
  dynamic day = "--";
  dynamic year = "--";
  bool picked = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: CustomTheme.mode,
        child: Center(
          child: Container(
            child: Form(
              child: Center(
                child: ListView(shrinkWrap: true, children: <Widget>[
                  Center(
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: EdgeInsets.all(32.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32.0, horizontal: 32.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Text(
                                    "What's your date of birth?",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Center(
                                    child: InkWell(
                                        onTap: () {
                                          DatePicker.showDatePicker(context,
                                              showTitleActions: true,
                                              minTime: DateTime(1900, 3, 5),
                                              maxTime: DateTime.now(),
                                              onChanged: (date) {
                                            print('change $date in time zone ' +
                                                date.timeZoneOffset.inHours
                                                    .toString());
                                            setState(() {
                                              month = date.month;
                                              day = date.day;
                                              year = date.year;
                                              picked = true;
                                            });
                                          }, onConfirm: (date) {
                                            birthday = date;
                                          },
                                              currentTime: DateTime.now(),
                                              locale: LocaleType.en);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            NumberLine(
                                                width: size.width * .15,
                                                text: "$month"),
                                            Text("/",
                                                style: TextStyle(fontSize: 25)),
                                            NumberLine(
                                                width: size.width * .15,
                                                text: "$day"),
                                            Text("/",
                                                style: TextStyle(fontSize: 25)),
                                            NumberLine(
                                                width: size.width * .2,
                                                text: "$year"),
                                          ],
                                        )),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                    text: 'Confirm',
                                    onPressed: () async {
                                      // Check for non-user
                                      if (picked) {
                                        Duration difference =
                                            DateTime.now().difference(birthday);
                                        num age = difference.inDays ~/ 365;
                                        if (age >= 18) {
                                          ZestiLoadingAsync().show(context);
                                          await DatabaseService(uid: user!.uid)
                                              .updateAge(age);
                                          ZestiLoadingAsync().dismiss();
                                          // Push to House form
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Name()),
                                          );
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  ageDialog(context));
                                        }
                                      }
                                    }),
                                SizedBox(
                                  width: double.infinity,
                                  height: size.height * 0.3,
                                  child: SvgPicture.asset("assets/birthday.svg",
                                      semanticsLabel: "Name"),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ageDialog(context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text('You must be 18 years or older to proceed.'),
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
          child: Text("Ok", style: CustomTheme.textTheme.headline2),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
