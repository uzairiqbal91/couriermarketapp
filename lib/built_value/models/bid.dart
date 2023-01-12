import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/built_value/models/group.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';

part 'bid.g.dart';

abstract class Bid implements Built<Bid, BidBuilder> {
  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'listing_id')
  int? get listingId;

  @BuiltValueField(wireName: 'bidder_group_id')
  int? get groupId;

  @BuiltValueField(wireName: 'group')
  Group? get group;

  @BuiltValueField(wireName: 'bidder_user_id')
  int? get userId;

  @BuiltValueField(wireName: 'cost_exc_vat')
  String? get costExcVat;

  @BuiltValueField(wireName: 'cost_inc_vat')
  String? get costIncVat;

  @BuiltValueField(wireName: 'vat')
  String? get vat;

  @BuiltValueField(wireName: 'note')
  String? get note;

  @BuiltValueField(wireName: 'state')
  String? get state;

  @BuiltValueField(wireName: 'contact_number')
  String? get contactNumber;

  @BuiltValueField(wireName: 'created_at')
  String? get createdAt;

  Bid._();

  factory Bid([void Function(BidBuilder)? updates]) = _$Bid;

  Map<String, dynamic>? toJson() {
    return serializers.serializeWith(Bid.serializer, this) as Map<String, dynamic>?;
  }

  static Bid? fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(Bid.serializer, json);
  }

  static Serializer<Bid> get serializer => _$bidSerializer;
}
