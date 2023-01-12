import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'invoice.g.dart';

abstract class Invoice implements Built<Invoice, InvoiceBuilder> {
  Invoice._();

  factory Invoice([void Function(InvoiceBuilder)? updates]) = _$Invoice;

  static Serializer<Invoice> get serializer => _$invoiceSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'state')
  String? get state;

  @BuiltValueField(wireName: 'pdf')
  String? get pdf;

  @BuiltValueField(wireName: 'vat')
  String? get vat;

  @BuiltValueField(wireName: 'cost_exc_vat')
  String? get costExcVat;

  @BuiltValueField(wireName: 'cost_inc_vat')
  String? get costIncVat;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  String toJson() {
    return json.encode(serializers.serializeWith(Invoice.serializer, this));
  }

  static Invoice? fromJson(String jsonString) {
    return serializers.deserializeWith(Invoice.serializer, json.decode(jsonString));
  }
}
