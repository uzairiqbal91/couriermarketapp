import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/enums/std_status.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'list_response.g.dart';

abstract class ListResponse<T> implements Built<ListResponse<T>, ListResponseBuilder<T>> {
  @BuiltValueField(wireName: 'status')
  StdStatus? get status;

  @BuiltValueField(wireName: 'message')
  String? get message;

  @BuiltValueField(wireName: 'data')
  BuiltList<T>? get data;

  ListResponse._();

  factory ListResponse([void Function(ListResponseBuilder<T>)? updates]) = _$ListResponse<T>;

  String toJson() => json.encode(serializers.serializeWith(ListResponse.serializer, this));

  static ListResponse<T>? fromJsonMap<T>(Map? jsonMap) => serializers.deserialize(
        jsonMap,
        specifiedType: FullType(ListResponse, [FullType(T)]),
      ) as ListResponse<T>?;

  static ListResponse<T>? fromJson<T>(String jsonString) => fromJsonMap<T>(json.decode(jsonString));

  static Serializer<ListResponse> get serializer => _$listResponseSerializer;
}
