import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:zesti/widgets/loading.dart';

// Widget to redeem discount codes.
class Deals extends StatelessWidget {
  Deals({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);
    return Drawer(
      child: Container(
        decoration: CustomTheme.standard,
        // StreamBuilder to load match stream.
        child: StreamBuilder(
          stream: DatabaseService(uid: user!.uid).getPartners(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            QuerySnapshot? tmp = snapshot.data;
            return tmp != null
                ? ListView.separated(
                    itemBuilder: (context, index) {
                      // First index is reserved for text "MATCHES".
                      if (index == 0) {
                        return Container(
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
                        );
                      }

                      // Remaining indeces used for matchsheet widgets.
                      Map<String, dynamic> data =
                          tmp.docs[index - 1].data() as Map<String, dynamic>;
                      return dealCard(
                          context,
                          tmp.docs[index - 1].id,
                          data['photo-ref'],
                          data['name'],
                          data['description'],
                          user.uid);
                    },
                    // A divider widgets is placed in between each matchsheet widget.
                    separatorBuilder: (context, index) => SizedBox(height: 8.0),
                    itemCount: tmp.docs.length + 1)
                // StreamBuilder loading indicator.
                : ZestiLoading();
          },
        ),
      ),
    );
  }

  // Card that displays a specific partner deal.
  Widget dealCard(BuildContext context, String partnerid, String imagePath,
      String vendor, String description, String uid) {
    final user = Provider.of<User?>(context);
    ImageProvider<Object> partnerPic = AssetImage("assets/profile.jpg");
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
                    partnerid: partnerid,
                    partnerPic: partnerPic,
                    vendor: vendor,
                    description: description,
                    uid: uid)),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              FutureBuilder(
                  future: DatabaseService(uid: user!.uid).getPhoto(imagePath),
                  builder:
                      (context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
                    // On error.
                    if (snapshot.hasError) {
                      return Text(snapshot.hasError.toString());
                      // On success.
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      partnerPic = snapshot.data!;
                      return CircleAvatar(
                        radius: 80.0,
                        backgroundImage: snapshot.data!,
                        backgroundColor: Colors.white,
                      );
                      // On loading, return an empty container.
                    } else {
                      return ZestiLoading();
                    }
                  }),
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
  final String partnerid;
  final ImageProvider<Object> partnerPic;
  final String vendor;
  final String description;
  final String uid;
  Redeem({
    Key? key,
    required this.partnerid,
    required this.partnerPic,
    required this.vendor,
    required this.description,
    required this.uid,
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
                    backgroundImage: widget.partnerPic,
                    backgroundColor: Colors.white),
                SizedBox(height: 20.0),
                Text(widget.vendor,
                    textAlign: TextAlign.center,
                    style: CustomTheme.textTheme.headline1),
                Text(widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24.0, fontFamily: 'Hind')),
                SizedBox(height: 20.0),
                RoundedButton(
                    text: 'Redeem',
                    onPressed: () async {
                      // Check for amount of uses left here for Grendel's
                      if (widget.partnerid != 'grendels') {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => redeemDialog(
                                  context,
                                  widget.partnerid,
                                  "Are you sure? Be ready to show the next screen to restaurant staff.",
                                  widget.vendor,
                                  widget.partnerPic,
                                ));
                      } else {
                        DocumentSnapshot snapshot =
                            await DatabaseService(uid: widget.uid)
                                .userCollection
                                .doc(widget.uid)
                                .collection('metrics')
                                .doc(widget.partnerid)
                                .get();
                        num remaining;
                        if (snapshot.exists) {
                          Map<String, dynamic> data =
                              snapshot.data() as Map<String, dynamic>;
                          remaining = 3 - data['count'];
                        } else {
                          remaining = 3;
                        }

                        if (remaining != 0) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => redeemDialog(
                                    context,
                                    widget.partnerid,
                                    "You have $remaining uses left for this coupon. Be ready to show the next screen to restaurant staff.",
                                    widget.vendor,
                                    widget.partnerPic,
                                  ));
                        } else {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => redeemFailDialog(context));
                        }
                      }
                    }),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget redeemDialog(BuildContext context, String partnerid, String message,
      String vendor, ImageProvider<Object> pic) {
    final user = Provider.of<User?>(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
            ZestiLoadingAsync().show(context);
            await DatabaseService(uid: user!.uid).redeemMetrics(partnerid);
            ZestiLoadingAsync().dismiss();
            Navigator.of(context).pop();
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => redeemedDialog(
                      context,
                      "You have redeemed the $vendor discount. Please show this to staff and then press 'Done'.",
                      pic,
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

  // On redeem success.
  Widget redeemedDialog(
      BuildContext context, String message, ImageProvider<Object> pic) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(message),
      content: SingleChildScrollView(
        child: CircleAvatar(
            radius: 120.0, backgroundImage: pic, backgroundColor: Colors.white),
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

  // When no limited use coupons left.
  Widget redeemFailDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text("You have no uses left for this coupon."),
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
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
