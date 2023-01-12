import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/api_exception.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/members.dart';
import 'package:courier_market_mobile/api/validators.dart';
import 'package:courier_market_mobile/fragments/app_drawer.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:fluttertoast/fluttertoast.dart';

class MembersInviteScreen extends StatelessWidget {
  static const activeScreen = MembersInviteScreenRoute.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Users')),
      drawer: AppDrawer(activeRoute: activeScreen),
      body: MembersInviteForm(),
    );
  }
}

class MembersInviteForm extends StatefulWidget {
  @override
  _MembersInviteFormState createState() => _MembersInviteFormState();
}

class _MembersInviteFormState extends State<MembersInviteForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _emailAddress;
  String? _userType;

  static const Map<String, String> _userTypeOpts = {
    'Sub User': 'Sub User',
    'Driver': 'Driver',
  };
  static final List<DropdownMenuItem<String>> _userTypeDrop =
      _userTypeOpts.entries.map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value))).toList();

  var _shouldAutoValidate = false;
  var isProcessing = false;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(children: [_buildInviteMemberSection()]),
      );

  Widget _buildInviteMemberSection() => Form(
        key: formKey,
        autovalidate: _shouldAutoValidate,
        child: Section(
          title: Text("Invite User / Driver"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "User Type"),
                items: _userTypeDrop,
                value: _userType,
                onChanged: (String? value) => setState(() => _userType = value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "First Name"),
                textInputAction: TextInputAction.next,
                onSaved: (value) => setState(() => _firstName = value),
                validator: Validators.validateNotEmpty,
                maxLength: 512,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Last Name"),
                textInputAction: TextInputAction.next,
                onSaved: (value) => setState(() => _lastName = value),
                validator: Validators.validateNotEmpty,
                maxLength: 512,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Email Address"),
                onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
                textInputAction: TextInputAction.done,
                onSaved: (value) => setState(() => _emailAddress = value),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateNotEmpty,
                maxLength: 512,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RaisedButton(
                        padding: null,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        child: Text("Submit"),
                        onPressed: () => _onSubmit()),
                  ),
                ],
              )
            ],
          ),
        ),
      );

  _onSubmit() async {
    setState(() => _shouldAutoValidate = true);
    if (!formKey.currentState!.validate()) return false;
    formKey.currentState!.save();

    setState(() => isProcessing = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(children: [
          Center(
            child: Column(children: [
              CircularProgressIndicator(),
              Divider(),
              Text("Please Wait"),
            ]),
          )
        ]),
      ),
    );

    try {
      final members = getIt<Members>();
      await members.invite(_userType, _firstName, _lastName, _emailAddress);

      Fluttertoast.showToast(msg: "Successfully Invited User!", toastLength: Toast.LENGTH_LONG);
      Navigator.of(context).pop();
    } on ApiException {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong, please try again!"),
      ));
    } finally {
      Navigator.of(context).pop();
    }
    setState(() => isProcessing = false);
  }
}
