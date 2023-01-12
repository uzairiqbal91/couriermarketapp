import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'listing_state.g.dart';

class ListingState extends EnumClass {
  const ListingState._(String name) : super(name);

  @BuiltValueEnumConst(wireName: "DRAFT")
  static const ListingState draft = _$a;

  @BuiltValueEnumConst(wireName: "ACTIVE", fallback: true)
  static const ListingState active = _$b;

  @BuiltValueEnumConst(wireName: "CONFIRMING")
  static const ListingState confirming = _$c;

  @BuiltValueEnumConst(wireName: "CONFIRMED")
  static const ListingState confirmed = _$d;

  @BuiltValueEnumConst(wireName: "IN-PROGRESS")
  static const ListingState in_progress = _$e;

  @BuiltValueEnumConst(wireName: "COMPLETE")
  static const ListingState complete = _$f;

  @BuiltValueEnumConst(wireName: "CANCELED")
  static const ListingState canceled = _$g;

  static ListingState valueOf(String name) => _$valueOf(name);

  static BuiltSet<ListingState> get values => _$values;

  static Serializer<ListingState> get serializer => _$listingStateSerializer;
}
