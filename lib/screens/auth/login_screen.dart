import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/build_config.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oauth2/oauth2.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
                child: Image.asset('assets/icons/logo.png'),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: LoginForm(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Platform.operatingSystem == 'ios'
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FlatButton(
                  child: const Text(
                    "Don't have an account?",
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => _createAccount(context),
                ),
              ],
            ),
    );
  }

  _createAccount(BuildContext context) async {
    var url = Uri.parse("${getIt<BuildConfig>().apiUrl}/../auth/register").toString();
    if (await url_launcher.canLaunch(url.toString())) {
      await url_launcher.launch(url);
    } else {
      Fluttertoast.showToast(msg: "Error launching browser");
    }
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _focusPswd = new FocusNode();
  final _formKey = GlobalKey<FormState>();

  final _ctrlEmail = new TextEditingController();
  final _ctrlPswd = new TextEditingController();

  bool isLoading = false;
  bool shouldValidate = false;

  String? errMsg;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stack(
        alignment: FractionalOffset(0.5, 1 / 3),
        children: <Widget>[
          AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _ctrlEmail,
                  readOnly: isLoading,
                  validator: (value) => validateNotEmpty(value) ?? validateNoSpace(value!),
                  autovalidate: shouldValidate,
                  autofillHints: isLoading ? null : [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (value) => FocusScope.of(context).requestFocus(_focusPswd),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: "Email Address",
                  ),
                ),
                TextFormField(
                  controller: _ctrlPswd,
                  obscureText: true,
                  readOnly: isLoading,
                  focusNode: _focusPswd,
                  validator: validateNotEmpty,
                  autovalidate: shouldValidate,
                  autofillHints: isLoading ? null : [AutofillHints.password],
                  onFieldSubmitted: (value) => submit(),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: "Password",
                  ),
                ),
                if (errMsg != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errMsg!,
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () => _openForgottenPassword(),
                    child: const Text("Forgotten Password?"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  child: RaisedButton(
                    onPressed: (isLoading ? null : submit),
                    child: const Text("Login"),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) CircularProgressIndicator(),
        ],
      ),
    );
  }

  Future<bool> submit() async {
    setState(() {
      this.shouldValidate = true;
      this.errMsg = null;
    });

    if (!_formKey.currentState!.validate()) return false;
    setState(() => this.isLoading = true);

    try {
      AuthUser? user = await getIt<Auth>().login(_ctrlEmail.text, _ctrlPswd.text);

      Fluttertoast.showToast(msg: "Logged in as: ${user!.firstName} ${user.lastName}", toastLength: Toast.LENGTH_LONG);

      setState(() => this.isLoading = false);
      AutoRouter.of(context).pushAndRemoveUntil(
        getIt<Auth>().authUser.value!.postLogin,
        predicate: (route) => false,
      );
      Future.delayed(
          Duration.zero,
          () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text("Welcome!"),
                  content: Text(
                      "For a better mobile experience, you can enable your location and notifications to always stay updated on the road!"),
                  actions: <Widget>[
                    RaisedButton(
                      child: Text("Yes, please"),
                      onPressed: () {
                        AutoRouter.of(context).push(AccountScreenRoute());
                      },
                    ),
                  ],
                ),
              ));

      return true;
    } on AuthorizationException {
      setState(() {
        this.isLoading = false;
        this.errMsg = "Email or Password Invalid!";
      });
      return false;
    } on SocketException {
      setState(() {
        this.isLoading = false;
        this.errMsg = "Could not connect. Please check your internet!";
      });
    } catch (e) {
      setState(() {
        this.isLoading = false;
        this.errMsg = "Something went wrong :(";
      });
      throw e; //Catch this in report to crashlytics
    }

    setState(() => this.isLoading = false);
    return false;
  }

  _openForgottenPassword() async {
    var url = Uri.parse("${getIt<BuildConfig>().apiUrl}/../auth/password/forgot").toString();
    if (await url_launcher.canLaunch(url.toString())) {
      await url_launcher.launch(url);
    } else {
      Fluttertoast.showToast(msg: "Error launching browser");
    }
  }

  String? validateNotEmpty(String? value) => value!.isEmpty ? 'This field is required!' : null;

  String? validateNoSpace(String value) => value.contains(' ') ? 'This field should have no spaces!' : null;
}
