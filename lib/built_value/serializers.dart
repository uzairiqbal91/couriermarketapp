import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:courier_market_mobile/built_value/enums/device_type.dart';
import 'package:courier_market_mobile/built_value/enums/feedback_type.dart';
import 'package:courier_market_mobile/built_value/enums/listing_state.dart';
import 'package:courier_market_mobile/built_value/enums/std_status.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/built_value/models/bid.dart';
import 'package:courier_market_mobile/built_value/models/device.dart';
import 'package:courier_market_mobile/built_value/models/feedback.dart';
import 'package:courier_market_mobile/built_value/models/group.dart';
import 'package:courier_market_mobile/built_value/models/invoice.dart';
import 'package:courier_market_mobile/built_value/models/lat_lng.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/built_value/models/map_marker.dart';
import 'package:courier_market_mobile/built_value/models/user.dart';
import 'package:courier_market_mobile/built_value/models/user_feedback_meta.dart';
import 'package:courier_market_mobile/built_value/models/user_registration.dart';
import 'package:courier_market_mobile/built_value/models/user_search.dart';
import 'package:courier_market_mobile/built_value/responses/list_response.dart';
import 'package:courier_market_mobile/built_value/responses/paginated_response.dart';
import 'package:courier_market_mobile/built_value/responses/std_response.dart';

import 'models/user_feedback.dart';

part 'serializers.g.dart';

@SerializersFor(const [
  //ENUM
  DeviceType,
  FeedbackType,
  ListingState,
  StdStatus,
  //MODEL
  AuthUser,
  Bid,
  Device,
  Feedback,
  Group,
  Invoice,
  LatLng,
  Listing,
  MapMarker,
  User,
  UserFeedback,
  UserFeedbackMeta,
  UserRegistration,
  UserSearch,
  //RESPONSES
  ListResponse,
  PaginatedResponse,
  StdDataResponse,
  StdResponse,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(ListResponse, [const FullType(UserSearch)]),
        () => ListResponseBuilder<UserSearch>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [const FullType(UserSearch)]),
        () => ListBuilder<UserSearch>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [const FullType(Feedback)]),
        () => ListBuilder<Feedback>(),
      )
//The Rest
      ..addBuilderFactory(
        const FullType(BuiltList, [const FullType(Listing)]),
        () => ListBuilder<Listing>(),
      )
      ..addBuilderFactory(
        const FullType(PaginatedResponse, [const FullType(Listing)]),
        () => PaginatedResponseBuilder<Listing>(),
      )
      ..addBuilderFactory(
        const FullType(StdDataResponse, [const FullType(Bid)]),
        () => StdDataResponseBuilder<Bid>(),
      )
      ..addBuilderFactory(
        const FullType(StdDataResponse, [const FullType(Group)]),
        () => StdDataResponseBuilder<Group>(),
      )
      ..add(Iso8601DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
