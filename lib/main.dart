import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/bookings.dart';
import 'package:courier_market_mobile/api/build_config.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:courier_market_mobile/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart' hide Router;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'api/prefs.dart';
import 'api/versions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ensureDependencies();
  final buildConfig = getIt<BuildConfig>();


  Logger.root.level = Foundation.kReleaseMode ? Level.INFO : Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });



  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  FirebaseAnalytics().setAnalyticsCollectionEnabled(buildConfig.env == Env.PRODUCTION);

  getIt<Auth>().authUser.addListener(() => handleNewUser(getIt<Auth>().authUser.value));
  handleNewUser(getIt<Auth>().authUser.value);

  runApp(ValueListenableProvider<AuthUser?>.value(
    value: getIt<Auth>().authUser,
    child: Application(),
  ));
}

void handleNewUser(AuthUser? user) {
  //Analytics
  FirebaseAnalytics().setUserId("${user?.id}");
  Crashlytics.instance.setUserIdentifier("${user?.id}");

  //Analytics
  if (user != null) getIt<Bookings>().syncProgressWithServer();
}

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _appRouter = getIt<Router>();


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firebaseMessaging.configure(
      onLaunch: _notificationHandler,
      onResume: _notificationHandler,
      onMessage: (Map<String, dynamic> message) async => print("onMessage: $message"),
    );

    // fcm token - creating and saving in preferences
    // _firebaseMessaging.getToken().then((value) {
    //   getIt<Prefs>().setfcmToken(value);
    // });
  }

  Future<dynamic> _notificationHandler(Map<String, dynamic> message) async {
    print("Calling Handler");
    print(message);
    //TODO(AAllport): Route to correct place
    switch (message['data']['goto_via']) {
      case "listings_location":
        getIt<Router>().push(ListingScreenLocationRoute());
        break;
      case "bookings":
        getIt<Router>().push(ListingScreenBookingsRoute());
        break;
      case "bookings_complete":
        getIt<Router>().push(ListingScreenBookingsCompleteRoute());
        break;
    }
    switch (message['data']['goto_res']) {
      case "listing":
        getIt<Router>().push(ListingDetailScreenRoute(listing: int.parse(message['data']['goto_id'])));
        break;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'GB'),
        const Locale('en'),
      ],
      title: 'Courier Market',
      darkTheme: CmkColors.darkTheme,
      theme: CmkColors.theme,
      routerDelegate: _appRouter.delegate(navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
      ]),
      routeInformationParser: _appRouter.defaultRouteParser(),
      builder: (context, child) {
        Intl.defaultLocale = Localizations.localeOf(context).toString();
        return child!;
      },
    );
  }
}
