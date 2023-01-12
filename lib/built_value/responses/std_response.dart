import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/enums/std_status.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';
import 'package:fluttertoast/fluttertoast.dart';

part 'std_response.g.dart';

abstract class Toastable {
  String? get message;

  StdStatus? get status;

  Future<bool> displayAsToast([String? msg]) => Fluttertoast.showToast(
        msg: msg ?? this.message!,
        textColor: this.status!.toColour,
      );
}

abstract class StdResponse with Toastable implements Built<StdResponse, StdResponseBuilder> {
  StdResponse._();

  factory StdResponse([void Function(StdResponseBuilder)? updates]) = _$StdResponse;

  static Serializer<StdResponse> get serializer => _$stdResponseSerializer;

  @BuiltValueField(wireName: 'status')
  StdStatus? get status;

  @BuiltValueField(wireName: 'message')
  String? get message;

  @BuiltValueField(wireName: 'id')
  int? get id;

  String toJson() {
    return json.encode(serializers.serializeWith(StdResponse.serializer, this));
  }

  static StdResponse? fromJson(String jsonString) {
    return serializers.deserializeWith(StdResponse.serializer, json.decode(jsonString));
  }
}

@BuiltValue()
abstract class StdDataResponse<T> with Toastable implements Built<StdDataResponse<T>, StdDataResponseBuilder<T>> {
  @BuiltValueField(wireName: 'status')
  StdStatus? get status;

  @BuiltValueField(wireName: 'message')
  String? get message;

  @BuiltValueField(wireName: 'data')
  T get data;

  StdDataResponse._();

  factory StdDataResponse([void Function(StdDataResponseBuilder<T>)? updates]) = _$StdDataResponse<T>;

  Map<String, dynamic>? toJson() {
    return serializers.serializeWith(StdDataResponse.serializer, this) as Map<String, dynamic>?;
  }

  static StdDataResponse<T>? fromJson<T>(Map<String, dynamic>? json) {
    return serializers.deserialize(
      json,
      specifiedType: FullType(StdDataResponse, [FullType(T)]),
    ) as StdDataResponse<T>?;
  }

  static Serializer<StdDataResponse> get serializer => _$stdDataResponseSerializer;
}
