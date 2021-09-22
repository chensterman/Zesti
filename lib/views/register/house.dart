import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/views/register/identity.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for the housing form
class House extends StatefulWidget {
  @override
  _HouseState createState() => _HouseState();
}

class _HouseState extends State<House> {
  final _formKey = GlobalKey<FormState>();
  dynamic _house;

  // List of Harvard houses
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
                                DropdownButton<String>(
                                  value: _house,
                                  hint: Text('Select'),
                                  style: TextStyle(color: Colors.black),
                                  isExpanded: true,
                                  items: _houseList.map((val) {
                                    return DropdownMenuItem(
                                        value: val, child: Text(val));
                                  }).toList(),
                                  onChanged: (String? val) {
                                    if (val == null) {
                                      print('Error');
                                    } else {
                                      setState(() {
                                        _house = val;
                                      });
                                    }
                                  },
                                ),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                    text: 'Continue',
                                    onPressed: () async {
                                      if (_house != null) {
                                        await DatabaseService(uid: user!.uid)
                                            .updateHouse(_house.toLowerCase());
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Identity()),
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
