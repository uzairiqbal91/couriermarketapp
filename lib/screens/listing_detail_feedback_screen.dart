import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/api/validators.dart';
import 'package:courier_market_mobile/built_value/enums/std_status.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ListingDetailFeedbackScreen extends StatelessWidget {
  final Listing? listing;

  ListingDetailFeedbackScreen({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Listing #${listing!.id} - Feedback"),
        ),
        body: FeedbackCreateForm(listing));
  }
}

class FeedbackCreateForm extends StatefulWidget {
  final Listing? listing;

  FeedbackCreateForm(this.listing);

  @override
  _FeedbackCreateFormState createState() => _FeedbackCreateFormState();
}

class _FeedbackCreateFormState extends State<FeedbackCreateForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  int _rateNumber = 5;
  String? _notesExternal;
  bool _escalate = false;
  String? _notesEscalation;

  var isProcessing = false;

  late AnimationController _expandController;

  late CurvedAnimation _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(children: [
            _buildSectionRating(),
            _buildSectionEscalate(),
            _buildSubmitButton(),
          ]),
        ),
      );

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  Widget _buildSectionRating() => Section(
        title: Text("Add Feedback"),
        child: Column(
          children: <Widget>[
            InputDecorator(
              decoration: InputDecoration(labelText: "Rating"),
              child: Row(
                children: [
                  Text("1"),
                  Expanded(
                    child: Slider(
                      value: _rateNumber.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _rateNumber.toString(),
                      onChanged: (value) {
                        setState(() => _rateNumber = value.round());

                        if (_rateNumber <= 1) {
                          _expandController.forward();
                        } else {
                          _expandController.reverse();
                        }
                      },
                    ),
                  ),
                  Text("5")
                ],
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Notes"),
              keyboardType: TextInputType.multiline,
              onChanged: (value) => setState(() => _notesExternal = value),
              minLines: 1,
              maxLines: 5,
              maxLength: 512,
            ),
          ],
        ),
      );

  Widget _buildSectionEscalate() {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: _expandAnimation,
      child: Section(
        title: Text("Escalation"),
        child: Column(
          children: [
            Text("As you've rated this Listing a 1, would you raise an escalation?"),
            Text("The escalation notes, will only be visible to the admin team"),
            SwitchListTile(
              title: Text("Raise Escalation?"),
              value: _escalate,
              onChanged: (bool value) => setState(() => _escalate = value),
            ),
            TextFormField(
              readOnly: !_escalate,
              decoration: InputDecoration(labelText: "Escalation Notes"),
              validator: Validators.validateIf(_escalate, Validators.validateRequired) as String? Function(String?)?,
              onChanged: (value) => setState(() => _notesEscalation = value),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RaisedButton(
          padding: null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Text("Submit"),
          onPressed: () => _onSubmit(),
        ),
      ),
    );
  }

  _onSubmit() async {
    if (!_formKey.currentState!.validate()) return false;
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
      final response = await getIt<Listings>().submitFeedback(
        widget.listing!,
        _rateNumber.toString(),
        _notesExternal,
        _escalate,
        _escalate ? _notesEscalation : null,
      );

      if (response!.status != StdStatus.success) {
        Fluttertoast.showToast(msg: response.message);
        Navigator.of(context).pop(true); //Pop the Loader
        return;
      }

      Fluttertoast.showToast(msg: "Successfully Submitted Feedback!");
      Navigator.of(context).pop(true); //Pop the loader
      Navigator.of(context).pop(); // Pop the feedback screen
    } catch (e) {
      Navigator.of(context).pop(true); //Pop the loader
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Something went wrong, please try again!"),
      ));
    } finally {
      setState(() => isProcessing = false); //Enable the form
    }
  }

  String? validateNotEmpty(String value) => value.isEmpty ? 'This field is required!' : null;
}
