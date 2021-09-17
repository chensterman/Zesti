import "package:flutter/material.dart";
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/auth/signup.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for handling login
class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // Validation of entered values
  final _formKey = GlobalKey<FormState>();

  // State of text fields
  String email = '';
  String password = '';

  // Error message when email is not valid
  String error = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: size.height * 0.1, horizontal: size.width * 0.1),
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
              CustomTheme.lightTheme.backgroundColor,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      Text('Login',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                              color: Colors.white)),
                      SizedBox(height: size.height * 0.05),
                      TextFieldContainer(
                        validator: (val) =>
                            val!.isEmpty ? 'Please enter an email' : null,
                        onChanged: (val) {
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
                            // Validate all form fields
                            if (_formKey.currentState!.validate()) {
                              // Get login status
                              int status =
                                  await AuthService().signIn(email, password);
                              // On success, push the authentication route
                              if (status == 0) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/auth',
                                );
                                // On failure, send the error message
                              } else {
                                print('Incorrect Login');
                              }
                            }
                          }),
                      SizedBox(height: size.height * 0.01),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Need an account ? ',
                              style: TextStyle(fontSize: 16.0),
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
                                    style: TextStyle(
                                      color: Colors.orange[900],
                                    ))),
                          ]),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
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
}
