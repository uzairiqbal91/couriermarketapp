import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/material.dart';

class DisplayMarshallScreen extends StatefulWidget {
  @override
  _DisplayMarshallScreenState createState() => _DisplayMarshallScreenState();
}

class _DisplayMarshallScreenState extends State<DisplayMarshallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () => AutoRouter.of(context).pushAndRemoveUntil(
        getIt<Auth>().isAuthenticated ? getIt<Auth>().authUser.value!.postLogin : LoginScreenRoute(),
        predicate: (route) => false,
      ),
    );
  }
}
