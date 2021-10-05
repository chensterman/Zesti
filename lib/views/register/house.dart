import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/views/register/info.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for the housing form
class House extends StatefulWidget {
  @override
  _HouseState createState() => _HouseState();
}

class _HouseState extends State<House> {
  final _formKey = GlobalKey<FormState>();

  // List of Harvard houses
  String? _house;
  List<String> _houseList = [
    'Apley Court',
    'Canaday',
    'Grays',
    'Greenough',
    'Hollis',
    'Holworthy',
    'Hurlbut',
    'Lionel',
    'Mower',
    'Massachusetts Hall',
    'Mathews',
    'Pennypacker',
    'Stoughton',
    'Straus',
    'Thayer',
    'Weld',
    'Wigglesworth',
    'Adams',
    'Cabot',
    'Currier',
    'Dunster',
    'Eliot',
    'Kirkland',
    'Leverett',
    'Lowell',
    'Mather',
    'Pfohozeimer',
    'Quincy',
    'Winthrop',
  ];

  // List of years
  String? _year;
  List<String> _yearList = [
    '\'22',
    '\'23',
    '\'24',
    '\'25',
  ];

  void houseCallback(String? val) {
    setState(() {
      _house = val;
    });
  }

  void yearCallback(String? val) {
    setState(() {
      _year = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
      ),
      body: Container(
        decoration: CustomTheme.mode,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
                vertical: size.height * CustomTheme.paddingMultiplier,
                horizontal: size.width * CustomTheme.paddingMultiplier),
            child: Form(
              key: _formKey,
              child: Center(
                child: ListView(shrinkWrap: true, children: <Widget>[
                  Center(
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32.0, horizontal: 32.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: size.height * 0.27,
                                  child: SvgPicture.asset("assets/harvard.svg",
                                      semanticsLabel: "Harvard"),
                                ),
                                SizedBox(height: 30.0),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "Which house do you live in?",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                DropDownField(
                                    callback: houseCallback,
                                    initValue: _house,
                                    houseList: _houseList),
                                SizedBox(height: 20.0),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "Which year do graduate?",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                DropDownField(
                                    callback: yearCallback,
                                    initValue: _year,
                                    houseList: _yearList),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                    text: 'Continue',
                                    onPressed: () async {
                                      if (_house != null && _year != null) {
                                        await DatabaseService(uid: user!.uid)
                                            .updateHouse(_house!);
                                        await DatabaseService(uid: user.uid)
                                            .updateYear(_year!);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Info()),
                                        );
                                      }
                                    }),
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
}
