import 'package:courier_market_mobile/api/bookings.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/built_value/responses/paginated_response.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:courier_market_mobile/screens/listing_screen.dart';
import 'package:flutter/material.dart';

class ListingScreenBookings extends ListingScreen {
  @override
  String get activeRoute => ListingScreenBookingsRoute.name;

  @override
  Text get title => const Text("My Bookings");

  @override
  bool get filter => true;

  @override
  Future<PaginatedResponse<Listing>?> listDelegate(
    BuildContext context,
    int page,
    int length,
    Map<String, dynamic> filters,
  ) =>
      getIt<Bookings>().list(
        page: page,
        length: length,
        filters: filters,
      );
}
