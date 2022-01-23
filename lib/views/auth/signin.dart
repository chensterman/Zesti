import "package:flutter/material.dart";
import 'package:zesti/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/views/auth/signup.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for handling login.
class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // Validation of entered values.
  final _formKey = GlobalKey<FormState>();

  // State of text fields.
  String email = '';
  String password = '';
  String resetEmail = '';

  void errorCallback() {
    String error = "Sign in error. The email or password is invalid.";
    showDialog(
        context: context, builder: (context) => errorDialog(context, error));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: size.height * CustomTheme.paddingMultiplier,
            horizontal: size.width * CustomTheme.paddingMultiplier),
        decoration: CustomTheme.standard,
        child: Form(
          key: _formKey,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      Text('Login', style: CustomTheme.textTheme.headline1),
                      SizedBox(height: size.height * 0.05),
                      TextFieldContainer(
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter an email' : null,
                        onChanged: (val) {
                          val = val.toLowerCase();
                          setState(() => email = val);
                        },
                        hintText: 'Email',
                        icon: Icon(Icons.person),
                      ),
                      SizedBox(height: size.height * 0.03),
                      TextFieldContainer(
                        obscureText: true,
                        validator: (val) => val!.length < 8
                            ? 'Password must be over 8 characters long'
                            : null,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                        hintText: 'Password',
                        icon: Icon(Icons.lock),
                      ),
                      SizedBox(height: size.height * 0.03),
                      RoundedButton(
                          text: 'Sign In',
                          onPressed: () async {
                            // Validate all form fields.
                            if (_formKey.currentState!.validate()) {
                              // Get login status.
                              int status = await AuthService()
                                  .signIn(email, password, errorCallback);
                              // On success, push the authentication route.
                              if (status == 0) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/auth',
                                );
                              }
                            }
                          }),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Need an account? ',
                            style: CustomTheme.textTheme.bodyText1,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()),
                                );
                              },
                              child: Text('Sign Up.',
                                  style: CustomTheme.textTheme.bodyText2)),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) =>
                                    resetConfirmDialog(context));
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                                color: CustomTheme.reallyBrightOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Hind'),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget resetConfirmDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title:
          Text("A password reset email will be sent to the email you provide."),
      content: SingleChildScrollView(
        child: TextFormField(
          onChanged: (val) {
            val = val.toLowerCase();
            setState(() => resetEmail = val);
          },
          decoration: const InputDecoration(hintText: "Email"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Send", style: CustomTheme.textTheme.headline1),
          onPressed: () async {
            await AuthService().resetPassword(resetEmail);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Cancel", style: CustomTheme.textTheme.headline2),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget errorDialog(BuildContext context, String error) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(error),
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
