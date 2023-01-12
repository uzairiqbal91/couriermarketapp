import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/material.dart';

part 'std_status.g.dart';

class StdStatus extends EnumClass {
  const StdStatus._(String name) : super(name);

  @BuiltValueEnumConst(wireName: "success")
  static const StdStatus success = _$a;

  @BuiltValueEnumConst(wireName: "danger")
  static const StdStatus danger = _$b;

  Color get toColour => (this == success ? Colors.lightGreen : Colors.amber);

  static StdStatus valueOf(String name) => _$valueOf(name);

  static BuiltSet<StdStatus> get values => _$values;

  static Serializer<StdStatus> get serializer => _$stdStatusSerializer;
}
