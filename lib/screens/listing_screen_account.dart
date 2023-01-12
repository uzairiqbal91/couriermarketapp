import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/listings.dart';
import 'package:courier_market_mobile/built_value/models/listing.dart';
import 'package:courier_market_mobile/built_value/responses/paginated_response.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:courier_market_mobile/screens/listing_screen.dart';
import 'package:flutter/material.dart';

class ListingScreenAccount extends ListingScreen {
  @override
  String get activeRoute => ListingScreenAccountRoute.name;

  @override
  Text get title => const Text("My Listings");

  @override
  Future<PaginatedResponse<Listing>?> listDelegate(
    BuildContext context,
    int page,
    int length,
    Map<String, dynamic> filters,
  ) =>
      getIt<Listings>().list(
        page: page,
        length: length,
        filter: Listings.FILTER_SHOW_ONLY_ME,
      );
}
