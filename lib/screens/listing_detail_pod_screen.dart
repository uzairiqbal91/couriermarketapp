import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/api/validators.dart';
import 'package:courier_market_mobile/built_value/enums/std_status.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/fragments/datetime_form_field.dart';
import 'package:courier_market_mobile/fragments/section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ListingDetailPodScreen extends StatelessWidget {
  final Listing? listing;

  ListingDetailPodScreen({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listing #${listing!.id} - POD"),
      ),
      body: PodForm(listing),
    );
  }
}

class PodForm extends StatefulWidget {
  final Listing? listing;

  PodForm(this.listing);

  @override
  _PodFormState createState() => _PodFormState();
}

class _PodFormState extends State<PodForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  bool autoValidate = false;
  bool isProcessing = false;

  TextEditingController fileController = TextEditingController();

  PickedFile? proof;
  String? recipient;
  DateTime? dateTime = DateTime.now();
  String? notes;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Section(
              title: Text("Enter POD"),
              child: Column(
                children: [
                  ButtonTheme.fromButtonThemeData(
                    data: Theme.of(context).buttonTheme.copyWith(
                          padding: const EdgeInsets.all(8),
                          minWidth: 0,
                        ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            enableInteractiveSelection: false,
                            readOnly: true,
                            controller: fileController,
                            decoration: InputDecoration(labelText: "Upload POD"),
                            autovalidate: autoValidate,
                            validator: Validators.validateNotEmpty,
                          ),
                        ),
                        SizedBox(width: 8),
                        RaisedButton(
                          child: Icon(Icons.image),
                          onPressed: () => _handleFilePicker(ImageSource.gallery),
                        ),
                        RaisedButton(
                          child: Icon(Icons.camera_alt),
                          onPressed: () => _handleFilePicker(ImageSource.camera),
                        ),
                      ],
                    ),
                  ),
                  if (proof != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        File(proof!.path),
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                    ),
                  DateTimeFormField(
                    decoration: InputDecoration(labelText: "Evidence Date"),
                    initialValue: DateTime.now(),
                    firstDate: DateTime.now().subtract(Duration(days: 14)),
                    lastDate: DateTime.now().add(Duration(days: 7)),
                    onSaved: (dt) => setState(() => dateTime = dt),
                    autovalidate: autoValidate,
                    validator: Validators.validateNotNull,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Received By"),
                    autovalidate: autoValidate,
                    validator: Validators.validateNotEmpty,
                    onSaved: (String? value) => setState(() => recipient = value),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Notes"),
                    onSaved: (String? value) => setState(() => notes = value!.isEmpty ? null : value),
                    minLines: 1,
                    maxLines: 5,
                  ),
                  RaisedButton(
                    child: Text("Submit"),
                    onPressed: _onSubmit,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _handleFilePicker(ImageSource src) async {
    PickedFile file;
    try {
      file = await _picker.getImage(
        source: src,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Can't access Camera!",
        textColor: StdStatus.danger.toColour,
      );
      return;
    }
    setState(() => proof = file);
    fileController.text = proof?.path?.split('/').last ?? '';
  }

  _onSubmit() async {
    setState(() => autoValidate = true);
    if (!_formKey.currentState!.validate()) return false;
    _formKey.currentState!.save();

    var response = _handleUpload();
    AutoRouter.of(context).pop();

    return await response;
  }

  _handleUpload() async {
    var listings = getIt<Listings>();
    var response = await (listings.submitPOD(
      widget.listing!,
      {
        'pod_received_by': recipient,
        'pod_received_on': dateTime!.toUtc().toIso8601String(),
        'pod_notes': notes,
      },
      File(proof!.path),
    ));

    response!.displayAsToast();
    return response;
  }
}
