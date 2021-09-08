import 'package:flutter/material.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/auth/signin.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for handling account creation
class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Validation of entered values
  final _formKey = GlobalKey<FormState>();

  // States likes these are needed when we pass in the values to Firebase
  // State of text fields
  String email = '';
  String password = '';
  String passwordConfirm = '';

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
              Colors.white,
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
                      Text('Sign Up',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                              color: Colors.white)),
                      SizedBox(height: size.height * 0.05),
                      TextFieldContainer(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter an email';
                          } else if (!val.endsWith('.edu')) {
                            return 'Email must be .edu';
                          }
                        },
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                        hintText: 'Email',
                        icon: Icon(Icons.person),
                      ),
                      SizedBox(height: size.height * 0.03),
                      TextFieldContainer(
                        validator: (val) => val!.length < 8
                            ? 'Password must be over 8 characters long'
                            : null,
                        obscureText: true,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                        hintText: 'Password',
                        icon: Icon(Icons.lock),
                      ),
                      SizedBox(height: size.height * 0.03),
                      TextFieldContainer(
                        validator: (val) =>
                            val != password ? 'Password do not match' : null,
                        obscureText: true,
                        onChanged: (val) {
                          setState(() => passwordConfirm = val);
                        },
                        hintText: 'Confirm Password',
                        icon: Icon(Icons.lock),
                      ),
                      SizedBox(height: size.height * 0.03),
                      RoundedButton(
                          text: 'Sign Up',
                          onPressed: () async {
                            // Validate form fields
                            if (_formKey.currentState!.validate()) {
                              // Once validated, auth service creates account
                              // Then push authentication route
                              await AuthService().signUp(email, password);
                              Navigator.pushReplacementNamed(
                                context,
                                '/auth',
                              );
                            }
                          }),
                      SizedBox(height: size.height * 0.01),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Already Zesti enough ? ',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignIn()),
                                  );
                                },
                                child: Text('Login.',
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
