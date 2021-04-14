import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/shared/input.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/views/register/birthday.dart';

class DropdownState extends StatefulWidget {
  const DropdownState({Key? key}) : super(key: key);

  @override
  Dropdown createState() => Dropdown();
}

class Dropdown extends State<DropdownState> {
  String dropdownValue = '+1';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      underline: Container(
        height: 2,
        color: CustomTheme.lightTheme.primaryColor,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>['+1', '+2', '+3', '+4']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class Name extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Container(
            width: size.width * CustomTheme.containerWidth,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "What's your name?",
                    style: CustomTheme.lightTheme.textTheme.headline1,
                  ),
                ),
                InputState(
                  width: size.width,
                  hintText: "First",
                ),
                InputState(
                  width: size.width,
                  hintText: "Last",
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: CustomTheme.lightTheme.primaryColor,
                          padding: const EdgeInsets.only(
                              left: 30, top: 10, right: 30, bottom: 10),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Birthday()),
                        );
                      },
                      child: Text("Continue"),
                    )),
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.3,
                  child: SvgPicture.asset("assets/name.svg",
                      semanticsLabel: "Name"),
                )
              ],
            )),
      ),
    );
  }
}
