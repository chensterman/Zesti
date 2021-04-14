//import 'package:aelo_prototype/screens/services/fireauth.dart';
import "package:flutter/material.dart";
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/auth/signup.dart';

class SignIn extends StatefulWidget {
  //final Function toggleView;
  //SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  //final AuthService _auth = AuthService();

  // Validation of entered values
  final _formKey = GlobalKey<FormState>();

  // State of text fields
  String email = '';
  String password = '';

  // Error message when email is not valid
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        elevation: 0.0,
        title: Text('Sign in to Zesti'),
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () {
                //widget.toggleView();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUp()),
                );
              },
              icon: Icon(Icons.person),
              label: Text('Sign Up'))
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        decoration: BoxDecoration(
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,

            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.3, 0.9],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              CustomTheme.lightTheme.primaryColor,
              Colors.white,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  }),
              SizedBox(height: 20.0),
              TextFormField(
                  validator: (val) => val!.length < 8
                      ? 'Password must be over 8 characters long'
                      : null,
                  obscureText: true,
                  onChanged: (val) {
                    setState(() => password = val);
                  }),
              SizedBox(height: 20.0),
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
                      //async {

                      if (_formKey.currentState!.validate()) {
                        /*
                        dynamic result = await _auth.signUpEmail(email, password);
                        if (result == null) {
                          setState(() => error = "Please enter a valid email");
                        }
                        */
                      }
                    },
                    child: Text("Sign in"),
                  )),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
