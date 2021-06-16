import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/views/register/identity.dart';
import 'package:zesti/widgets/formwidgets.dart';

class House extends StatefulWidget {
  @override
  _HouseState createState() => _HouseState();
}

class _HouseState extends State<House> {
  final _formKey = GlobalKey<FormState>();
  String _house = '';
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
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
          width: size.width * CustomTheme.containerWidth,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.27,
                  child: SvgPicture.asset("assets/harvard.svg",
                      semanticsLabel: "Harvard"),
                ),
                SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Which house do you live in?",
                    style: CustomTheme.lightTheme.textTheme.headline1,
                  ),
                ),
                SizedBox(height: 20.0),
                DropdownButton<String>(
                  value: null,
                  hint: Text('Select'),
                  style: TextStyle(color: Colors.black),
                  isExpanded: true,
                  items: _houseList.map((val) {
                    return DropdownMenuItem(value: val, child: Text(val));
                  }).toList(),
                  onChanged: (val) {
                    if (val == null) {
                      print('Error');
                    } else {
                      setState(() {
                        _house = val.toLowerCase();
                      });
                    }
                  },
                ),
                SizedBox(height: 20.0),
                RoundedButton(
                    text: 'Continue',
                    onPressed: () async {
                      if (user == null) {
                        print("Error");
                      } else {
                        await DatabaseService(uid: user.uid)
                            .updateHouse(_house);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Identity()),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
