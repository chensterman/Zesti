import "package:flutter/material.dart";
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/auth/signup.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:zesti/wrappers/authwrapper.dart';

class SignIn extends StatefulWidget {
  //final Function toggleView;
  //SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // final AuthService _auth = AuthService();

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.0),
              Text('Login',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32.0,
                      color: Colors.white)),
              SizedBox(height: 20.0),
              TextFieldContainer(
                validator: (val) =>
                    val!.isEmpty ? 'Please enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
                hintText: 'Email',
                icon: Icon(Icons.person),
              ),
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
              RoundedButton(
                  text: 'Sign In',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      int status = await AuthService().signIn(email, password);
                      if (status == 0) {
                        Navigator.pushReplacementNamed(
                          context,
                          '/auth',
                        );
                      } else {
                        print('Incorrect Login');
                      }
                    }
                  }),
              SizedBox(height: 12.0),
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
                            MaterialPageRoute(builder: (context) => SignUp()),
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
      ),
    );
  }
}
