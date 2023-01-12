import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'paginated_response.g.dart';

abstract class PaginatedResponse<T> implements Built<PaginatedResponse<T>, PaginatedResponseBuilder<T>> {
  @BuiltValueField(wireName: 'current_page')
  int? get currentPage;

  @BuiltValueField(wireName: 'data')
  BuiltList<T>? get data;

  @BuiltValueField(wireName: 'first_page_url')
  String? get firstPageUrl;

  @BuiltValueField(wireName: 'from')
  int? get from;

  @BuiltValueField(wireName: 'last_page')
  int? get lastPage;

  @BuiltValueField(wireName: 'last_page_url')
  String? get lastPageUrl;

  @BuiltValueField(wireName: 'next_page_url')
  String? get nextPageUrl;

  @BuiltValueField(wireName: 'path')
  String? get path;

  @BuiltValueField(wireName: 'per_page')
  int? get perPage;

  @BuiltValueField(wireName: 'prev_page_url')
  String? get prevPageUrl;

  @BuiltValueField(wireName: 'to')
  int? get to;

  @BuiltValueField(wireName: 'total')
  int? get total;

  PaginatedResponse._();

  factory PaginatedResponse([void Function(PaginatedResponseBuilder<T>)? updates]) = _$PaginatedResponse<T>;

  String toJson() => json.encode(serializers.serializeWith(PaginatedResponse.serializer, this));

  static PaginatedResponse<T>? fromJsonMap<T>(Map? jsonMap) => serializers.deserialize(
        jsonMap,
        specifiedType: FullType(PaginatedResponse, [FullType(T)]),
      ) as PaginatedResponse<T>?;

  static PaginatedResponse<T>? fromJson<T>(String jsonString) => fromJsonMap<T>(json.decode(jsonString));

  static Serializer<PaginatedResponse> get serializer => _$paginatedResponseSerializer;
}
