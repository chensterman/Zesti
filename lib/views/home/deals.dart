import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget to redeem discount codes.
class Deals extends StatelessWidget {
  Deals({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Drawer(
      child: Container(
        decoration: CustomTheme.standard,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              color: CustomTheme.reallyBrightOrange,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.15,
                    child: SvgPicture.asset("assets/zesti.svg",
                        semanticsLabel: "Zesti"),
                  ),
                  Text(
                    'Deals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ],
              ),
            ),
            dealCard(context, "assets/amorino.jpg", "AMORINO",
                "20% off of the Spring and Summer menu!"),
            dealCard(context, "assets/grendels.jpg", "GRENDEL'S DEN",
                "Free \$20 gift card for each visit (max 3)!"),
            dealCard(context, "assets/zinnekens.jpg", "ZINNEKEN'S",
                "20% off of any purchase!"),
            dealCard(context, "assets/maharaja.jpg", "THE MAHARAJA",
                "Anything off of the dessert menu, on the house!"),
          ],
        ),
      ),
    );
  }

  // Card that displays a specific partner deal.
  Widget dealCard(BuildContext context, String imagePath, String vendor,
      String description) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        splashColor: CustomTheme.reallyBrightOrange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Redeem(
                    imagePath: imagePath,
                    vendor: vendor,
                    description: description)),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage(imagePath),
                  backgroundColor: Colors.white),
              SizedBox(height: 16.0),
              Text(vendor,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[900], fontSize: 24.0)),
              Text(description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0)),
            ],
          ),
        ),
      ),
    );
  }
}

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
        backgroundColor: CustomTheme.reallyBrightOrange,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: size.height * CustomTheme.paddingMultiplier,
              horizontal: size.width * CustomTheme.paddingMultiplier),
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
                    style: CustomTheme.textTheme.headline1),
                Text(widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24.0, fontFamily: 'Hind')),
                // SizedBox(height: 20.0),
                // TextFormField(
                //     validator: (val) {
                //       if (val == null || val.isEmpty) {
                //         return "Please enter the correct coupon code.";
                //       }
                //     },
                //     onChanged: (val) {
                //       setState(() => code = val);
                //     },
                //     decoration: const InputDecoration(
                //         hintText: "Enter staff code here")),
                SizedBox(height: 20.0),
                RoundedButton(
                    text: 'Redeem',
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => redeemDialog(
                                context,
                                "Are you sure? Do not redeem this coupon until you are ready to present it to the restaurant staff. If this coupon has limited uses, proceeding will deplete one use.",
                              ));
                    }),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget redeemDialog(BuildContext context, String message) {
    return AlertDialog(
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
          child: Text("Yes", style: CustomTheme.textTheme.headline2),
          onPressed: () async {
            Navigator.pop(context);
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => redeemedDialog(
                      context,
                      "You have redeemed the Amorino discount. Please show this to staff and then press 'Done'.",
                    ));
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

  Widget redeemedDialog(BuildContext context, String message) {
    return AlertDialog(
      title: Text(message),
      content: SingleChildScrollView(
        child: CircleAvatar(
            radius: 120.0,
            backgroundImage: AssetImage("assets/amorino.jpg"),
            backgroundColor: Colors.white),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Done", style: CustomTheme.textTheme.headline2),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
