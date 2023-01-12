import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/router/auth_guard.dart';
import 'package:courier_market_mobile/screens/account_screen.dart';
import 'package:courier_market_mobile/screens/auth/login_screen.dart';
import 'package:courier_market_mobile/screens/display_marshall_screen.dart';
import 'package:courier_market_mobile/screens/listing_create_screen.dart';
import 'package:courier_market_mobile/screens/listing_detail_feedback_screen.dart';
import 'package:courier_market_mobile/screens/listing_detail_pod_screen.dart';
import 'package:courier_market_mobile/screens/listing_detail_screen.dart';
import 'package:courier_market_mobile/screens/listing_screen.dart';
import 'package:courier_market_mobile/screens/listing_screen_account.dart';
import 'package:courier_market_mobile/screens/listing_screen_bookings.dart';
import 'package:courier_market_mobile/screens/listing_screen_bookings_complete.dart';
import 'package:courier_market_mobile/screens/listing_screen_location.dart';
import 'package:courier_market_mobile/screens/members_invite_screen.dart';
import 'package:courier_market_mobile/screens/members_search_detail_screen.dart';
import 'package:courier_market_mobile/screens/members_search_screen.dart';

@MaterialAutoRouter(routes: <AutoRoute>[
  AutoRoute(page: DisplayMarshallScreen, initial: true),
  AutoRoute(page: LoginScreen, path: '/auth/login'),
  AutoRoute(page: AccountScreen, path: '/account', guards: [AuthGuard]),
  AutoRoute(page: ListingScreen, path: '/listing', guards: [AuthGuard]),
  AutoRoute(page: ListingScreenAccount, path: '/listing/account', guards: [AuthGuard]),
  AutoRoute(page: ListingScreenLocation, path: '/listing/location', guards: [AuthGuard]),
  AutoRoute(page: ListingScreenBookings, path: '/listing/bookings', guards: [AuthGuard]),
  AutoRoute(page: ListingScreenBookingsComplete, path: '/listing/bookings/complete', guards: [AuthGuard]),
  AutoRoute(page: ListingCreateScreen, path: '/listing/create', guards: [AuthGuard]),
  AutoRoute(page: ListingDetailScreen, path: '/listing/detail', guards: [AuthGuard]),
  AutoRoute(page: ListingDetailFeedbackScreen, path: '/listing/detail/feedback', guards: [AuthGuard]),
  AutoRoute(page: ListingDetailPodScreen, path: '/listing/detail/pod', guards: [AuthGuard]),
  AutoRoute(page: MembersSearchScreen, path: '/members', guards: [AuthGuard]),
  AutoRoute(page: MembersSearchDetailScreen, path: '/members/detail', guards: [AuthGuard]),
  AutoRoute(page: MembersInviteScreen, path: '/members/invite', guards: [AuthGuard]),
])
class $Router {}
