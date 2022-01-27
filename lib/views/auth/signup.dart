import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/auth/signin.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for handling account creation.
class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Validation of entered values.
  final _formKey = GlobalKey<FormState>();

  // States likes these are needed when we pass in the values to Firebase.
  // State of text fields.
  String email = '';
  String password = '';
  String passwordConfirm = '';

  // State of password obscurer
  bool passObscure = true;
  Icon passObscureIcon = Icon(Icons.visibility);

  // Error message when email is not valid.
  String error = '';

  void errorCallback() {
    String error = "Sign up error. This email may already be registered.";
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
                      Text('Sign Up', style: CustomTheme.textTheme.headline1),
                      SizedBox(height: size.height * 0.05),
                      TextFieldContainer(
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter an email';
                          }

                          val = val.toLowerCase();
                          if (!val.endsWith('college.harvard.edu') &&
                              val != "admin@test.edu") {
                            return 'Email must be Harvard College.';
                          }
                        },
                        onChanged: (val) {
                          val = val.toLowerCase();
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
                        obscureText: passObscure,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                        hintText: 'Password',
                        icon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            // Logic to reveal typed password
                            if (passObscure) {
                              setState(() =>
                                  passObscureIcon = Icon(Icons.visibility_off));
                            } else {
                              setState(() =>
                                  passObscureIcon = Icon(Icons.visibility));
                            }
                            setState(() => passObscure = !passObscure);
                          },
                          icon: passObscureIcon,
                        ),
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
                            // Validate form fields.
                            if (_formKey.currentState!.validate()) {
                              // Once validated, auth service creates account.
                              // Then push authentication route.
                              int status = await AuthService()
                                  .signUp(email, password, errorCallback);
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
                              'Already Zesti enough? ',
                              style: CustomTheme.textTheme.bodyText1,
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignIn()),
                                  );
                                },
                                child: Text(
                                  'Login.',
                                  style: CustomTheme.textTheme.bodyText2,
                                )),
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
