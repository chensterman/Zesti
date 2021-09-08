import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget to redeem discount codes.
class Redeem extends StatefulWidget {
  final String imagePath;
  final String vendor;
  final String description;
  Redeem({
    Key? key,
    required this.imagePath,
    required this.vendor,
    required this.description,
  }) : super(key: key);

  @override
  _RedeemState createState() => _RedeemState();
}

class _RedeemState extends State<Redeem> {
  final _formKey = GlobalKey<FormState>();
  String code = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
      ),
      body: Center(
        child: Container(
          width: size.width * CustomTheme.containerWidth,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                    radius: 80.0,
                    backgroundImage: AssetImage(widget.imagePath),
                    backgroundColor: Colors.white),
                SizedBox(height: 20.0),
                Text(widget.vendor,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.orange[900], fontSize: 24.0)),
                Text(widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24.0)),
                SizedBox(height: 20.0),
                TextFormField(
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Please enter the correct coupon code.";
                      }
                    },
                    onChanged: (val) {
                      setState(() => code = val);
                    },
                    decoration:
                        const InputDecoration(hintText: "Enter code here")),
                SizedBox(height: 20.0),
                RoundedButton(text: 'Redeem', onPressed: () {}),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
