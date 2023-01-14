import 'dart:convert';

class Version {
  MobileVersion? androidVersion;
  MobileVersion? iosVersion;

  Version({this.androidVersion, this.iosVersion});

  Version.fromJson(String jsonString) {

    Map json = jsonDecode(jsonString);
    androidVersion = json['androidVersion'] != null
        ? new MobileVersion.fromJson(json['androidVersion'])
        : null;
    iosVersion = json['iosVersion'] != null
        ? new MobileVersion.fromJson(json['iosVersion'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.androidVersion != null) {
      data['androidVersion'] = this.androidVersion?.toJson();
    }
    if (this.iosVersion != null) {
      data['iosVersion'] = this.iosVersion?.toJson();
    }
    return data;
  }
}

class MobileVersion {
  int? code;
  String? name;

  MobileVersion({this.code, this.name});

  MobileVersion.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    return data;
  }
}