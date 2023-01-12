import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:courier_market_mobile/api/num_util.dart';
import 'package:courier_market_mobile/built_value/enums/listing_state.dart';
import 'package:courier_market_mobile/built_value/models/bid.dart';
import 'package:courier_market_mobile/built_value/models/feedback.dart';
import 'package:courier_market_mobile/built_value/models/group.dart';
import 'package:courier_market_mobile/built_value/models/invoice.dart';
import 'package:courier_market_mobile/built_value/models/lat_lng.dart';
import 'package:courier_market_mobile/built_value/models/map_marker.dart';
import 'package:courier_market_mobile/built_value/models/user.dart';
import 'package:courier_market_mobile/built_value/serializers.dart';
import 'package:intl/intl.dart';

part 'listing.g.dart';

abstract class Listing implements Built<Listing, ListingBuilder> {
  Listing._();

  factory Listing([void Function(ListingBuilder)? updates]) = _$Listing;

  static Serializer<Listing> get serializer => _$listingSerializer;

  @BuiltValueField(wireName: 'id')
  int? get id;

  @BuiltValueField(wireName: 'book_status')
  bool? get bookStatus;

  @BuiltValueField(wireName: 'can_view')
  bool? get canView;

  @BuiltValueField(wireName: 'owner_group_id')
  int? get ownerGroupId;

  @BuiltValueField(wireName: 'owner_group')
  Group? get ownerGroup;

  @BuiltValueField(wireName: 'owner_user_id')
  int? get ownerUserId;

  @BuiltValueField(wireName: 'owner_user')
  User? get ownerUser;

  @BuiltValueField(wireName: 'owner_phone_number')
  String? get ownerPhoneNumber;

  @BuiltValueField(wireName: 'haulier_id')
  int? get haulierId;

  @BuiltValueField(wireName: 'haulier')
  Group? get haulier;

  @BuiltValueField(wireName: 'driver_id')
  int? get driverId;

  @BuiltValueField(wireName: 'driver')
  User? get driver;

  @BuiltValueField(wireName: 'internal_ref')
  String? get internalRef;

  @BuiltValueField(wireName: 'tracking_id')
  String? get trackingId;

  @BuiltValueField(wireName: 'state')
  ListingState? get state;

  @BuiltValueField(wireName: 'job_type')
  String? get jobType;

  @BuiltValueField(wireName: 'pickup_address')
  String? get pickupAddress;

  @BuiltValueField(wireName: 'pickup_placeid')
  String? get pickupPlaceid;

  @BuiltValueField(wireName: 'pickup_location')
  LatLng? get pickupLocation;

  @BuiltValueField(wireName: 'pickup_postcode')
  String? get pickupPostcode;

  @BuiltValueField(wireName: 'pickup_time')
  DateTime? get pickupTime;

  @BuiltValueField(wireName: 'pickup_within')
  String? get pickupWithin;

  @BuiltValueField(wireName: 'pickup_company')
  String? get pickupCompany;

  @BuiltValueField(wireName: 'pickup_contact')
  String? get pickupContact;

  @BuiltValueField(wireName: 'pickup_number')
  String? get pickupNumber;

  String pickupFmt([DateFormat? format]) => _timeFmt(pickupTime, pickupWithin, format);

  @BuiltValueField(wireName: 'dropoff_address')
  String? get dropoffAddress;

  @BuiltValueField(wireName: 'dropoff_placeid')
  String? get dropoffPlaceid;

  @BuiltValueField(wireName: 'dropoff_location')
  LatLng? get dropoffLocation;

  @BuiltValueField(wireName: 'dropoff_postcode')
  String? get dropoffPostcode;

  @BuiltValueField(wireName: 'dropoff_time')
  DateTime? get dropoffTime;

  @BuiltValueField(wireName: 'dropoff_within')
  String? get dropoffWithin;

  @BuiltValueField(wireName: 'dropoff_company')
  String? get dropoffCompany;

  @BuiltValueField(wireName: 'dropoff_contact')
  String? get dropoffContact;

  @BuiltValueField(wireName: 'dropoff_number')
  String? get dropoffNumber;

  String dropoffFmt([DateFormat? format]) => _timeFmt(dropoffTime, dropoffWithin, format);

  @BuiltValueField(wireName: 'pay_term')
  String? get payTermListing;

  String? get payTerm => payTermListing ?? ownerGroup!.paymentTerms;

  @BuiltValueField(wireName: 'pay_ex_vat')
  double? get payExVat;

  @BuiltValueField(wireName: 'pay_inc_vat')
  double? get payIncVat;

  @BuiltValueField(wireName: 'vehicle_load')
  String? get vehicleLoad;

  @BuiltValueField(wireName: 'vehicle_suggestion')
  BuiltList<String>? get vehicleSuggestion;

  @BuiltValueField(wireName: 'vehicle_freight')
  String? get vehicleFreight;

  @BuiltValueField(wireName: 'vehicle_body')
  BuiltList<String>? get vehicleBody;

  @BuiltValueField(wireName: 'est_distance')
  int? get estDistance;

  @BuiltValueField(wireName: 'est_time')
  int? get estTime;

  @BuiltValueField(wireName: 'est_via')
  String? get estVia;

  @BuiltValueField(wireName: 'notes_external')
  String? get notesExternal;

  @BuiltValueField(wireName: 'pod_document')
  String? get podDocument;

  @BuiltValueField(wireName: 'pod_received_by')
  String? get podReceivedBy;

  @BuiltValueField(wireName: 'pod_received_on')
  DateTime? get podReceivedOn;

  String? podReceivedOnFmt([DateFormat? format]) =>
      podReceivedOn == null ? null : (format ?? DateFormat.yMd().add_jm()).format(podReceivedOn!.toLocal());

  @BuiltValueField(wireName: 'pod_notes')
  String? get podNotes;

  @BuiltValueField(wireName: 'invoice')
  Invoice? get invoice;

  @BuiltValueField(wireName: 'bids')
  BuiltList<Bid>? get bids;

  @BuiltValueField(wireName: 'feedback')
  BuiltList<Feedback>? get feedback;

  @BuiltValueField(wireName: 'map_markers')
  BuiltMap<String, MapMarker>? get mapMarkers;

  @BuiltValueField(wireName: 'published_at')
  DateTime? get publishedAt;

  @BuiltValueField(wireName: 'booking_made') //TODO(AAllport): Update to `booked_at`
  DateTime? get bookedAt;

  String? bookedAtFmt([DateFormat? format]) =>
      bookedAt == null ? null : (format ?? DateFormat.yMd().add_jm()).format(bookedAt!.toLocal());

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: 'deleted_at')
  DateTime? get deletedAt;

  String? get estDistanceFmt => estDistance != null ? "${NumUtil.kmToMiles(estDistance! / 1000).round()} mi" : null;

  Duration? get estDuration => estTime != null ? Duration(seconds: estTime!) : null;

  String? get estDurationFmt => estDuration != null ? NumUtil.durationToPretty(estDuration!) : null;

  String _timeFmt(DateTime? time, String? within, [DateFormat? format]) {
    if (within != null) {
      return within;
    }
    if (time != null) {
      return (format ?? DateFormat.yMd().add_jm()).format(time.toLocal());
    }
    return "ASAP";
  }

  bool isOwnedByGroup(Group group) => this.ownerGroupId == group.id;

  bool isOwnedByUser(IUser user) => this.ownerUserId == user.id;

  bool isOwnedBy(target) {
    assert((target is IUser) || (target is Group));
    if (target is IUser) {
      return isOwnedByUser(target);
    } else if (target is Group) {
      return isOwnedByGroup(target);
    } else {
      throw ArgumentError("Target must be IUser or Group");
    }
  }

  Bid? ownBid(dynamic target) => !isOwnedBy(target) && this.bids!.length != 0 ? this.bids![0] : null;

  String toJson() {
    return json.encode(serializers.serializeWith(Listing.serializer, this));
  }

  static Listing? fromJson(String jsonString) {
    return serializers.deserializeWith(Listing.serializer, json.decode(jsonString));
  }
}
