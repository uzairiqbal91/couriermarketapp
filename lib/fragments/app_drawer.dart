import 'package:auto_route/auto_route.dart';
import 'package:courier_market_mobile/api/auth.dart';
import 'package:courier_market_mobile/api/bookings.dart';
import 'package:courier_market_mobile/api/container.dart';
import 'package:courier_market_mobile/api/location_provider.dart';
import 'package:courier_market_mobile/api/prefs.dart';
import 'package:courier_market_mobile/built_value/models/auth_user.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppDrawer extends StatelessWidget {
  final String? activeRoute;

  AppDrawer({this.activeRoute, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
        key: GlobalKey(debugLabel: "app_drawer"),
        child: ValueListenableBuilder(
          valueListenable: getIt<Auth>().authUser,
          builder: (BuildContext context, AuthUser? user, Widget? child) => user == null
              ? Container()
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      currentAccountPicture:
                          CircleAvatar(backgroundImage: user == null ? null : NetworkImage(user.avatarUrl)),
                      accountName: Text("${user.firstName} ${user.lastName}"),
                      accountEmail: Text("Member ID: #${user.groupId}\n${user.email}"),
                    ),
                    ValueListenableBuilder<LocationTrackingLevel>(
                      valueListenable: getIt<LocationProvider>().trackingLevel,
                      builder: (BuildContext context, LocationTrackingLevel value, Widget? child) => SwitchListTile(
                  value: value != LocationTrackingLevel.NONE,
                  onChanged: (bool value) async {
                    if (value == true) return await getIt<Bookings>().setIsOnline(true);
                    var result = await _confirmOffline(context);
                    if (result != null) await getIt<Bookings>().setIsOnline(false);
                  },
                  secondary: value == LocationTrackingLevel.NONE ? Icon(Icons.location_off) : Icon(Icons.location_on),
                  title: Text(value == LocationTrackingLevel.NONE ? "Offline" : "Online"),
                  subtitle: getIt<Prefs>().jobsInProgress.length > 0
                      ? Text("${getIt<Prefs>().jobsInProgress.length} jobs in progress")
                      : null,
                ),
              ),
              _GotoListTile(
                leading: FaIcon(FontAwesomeIcons.solidUser),
                title: Text("My Account"),
                goto: AccountScreenRoute(),
                current: activeRoute,
              ),
              if (user.can('listing.list'))
                      _GotoListTile(
                        leading: Icon(Icons.view_headline),
                        title: Text("My Listings"),
                        goto: ListingScreenAccountRoute(),
                        current: activeRoute,
                      ),
              if (user.can('listing.create'))
                _GotoListTile(
                  leading: Icon(Icons.view_compact),
                  title: Text("Create Listing"),
                  goto: ListingCreateScreenRoute(),
                  current: activeRoute,
                ),
              if (user.can('listing.list'))
                _GotoListTile(
                  leading: FaIcon(FontAwesomeIcons.globeEurope),
                  title: Text("All Jobs"),
                  goto: ListingScreenRoute(),
                  current: activeRoute,
                ),
              if (user.can('listing.list'))
                _GotoListTile(
                  leading: Icon(Icons.location_on),
                  title: Text("Nearby Jobs"),
                  goto: ListingScreenLocationRoute(),
                  current: activeRoute,
                ),
              Divider(),
              if (user.can('listing.view'))
                _GotoListTile(
                  leading: FaIcon(FontAwesomeIcons.solidHeart),
                  title: Text("My Bookings"),
                  goto: ListingScreenBookingsRoute(),
                  current: activeRoute,
                ),
              if (user.can('listing.list'))
                _GotoListTile(
                  leading: Icon(Icons.mail),
                  title: Text("Completed Bookings"),
                  goto: ListingScreenBookingsCompleteRoute(),
                  current: activeRoute,
                ),
              Divider(),
              if (user.can('listing.list'))
                _GotoListTile(
                  leading: Icon(Icons.search),
                  title: Text("Members Search"),
                  goto: MembersSearchScreenRoute(),
                  current: activeRoute,
                ),
              if (user.can('listing.list'))
                _GotoListTile(
                  leading: Icon(Icons.person_add),
                  title: Text("Add Users"),
                  goto: MembersInviteScreenRoute(),
                  current: activeRoute,
                ),
              Divider(),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.signOutAlt),
                title: Text("Logout"),
                onTap: () => _confirmLogout(context),
              )
            ],
          ),
        ),
      );

  Future<bool?> _confirmOffline(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("Are you sure you want to mark offline?"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          RaisedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Offline"),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (contextDialog) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("Are you sure you want to log out?"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(contextDialog),
            child: Text("Cancel"),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pop(contextDialog);
              Future.delayed(Duration(milliseconds: 250), () {
                return getIt<Auth>().logout(context: context);
              });
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}

class _GotoListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final String? current;
  final PageRouteInfo? goto;
  final dynamic gotoArgs;

  const _GotoListTile({
    this.leading,
    this.goto,
    required this.title,
    required this.current,
    this.gotoArgs,
    Key? key,
  }) : super(key: key);

  bool get isActive => this.current == this.goto!.routeName;

  bool get isDisabled => isActive || this.goto == null;

  Widget _disabledText(BuildContext ctx, Widget child) => DefaultTextStyle.merge(
        style: TextStyle(color: Theme.of(ctx).disabledColor),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isActive ? Theme.of(context).focusColor : null,
      child: ListTile(
        leading: leading,
        title: goto == null ? _disabledText(context, title) : title,
        onTap: isDisabled ? null : () => AutoRouter.of(context).popAndPush(goto!),
      ),
    );
  }
}
