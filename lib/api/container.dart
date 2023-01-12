import 'package:courier_market_mobile/api/build_config.dart';
import 'package:courier_market_mobile/api/container.config.dart';
import 'package:courier_market_mobile/api/prefs.dart';
import 'package:courier_market_mobile/router/auth_guard.dart';
import 'package:courier_market_mobile/router/router.gr.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info/package_info.dart';

final getIt = GetIt.instance;

const ENV = "env";
const HEADLESS = "headless";

Future<void> ensureDependencies([isHeadless = false]) async {
  if (getIt.isRegistered<String>(instanceName: ENV)) return;
  await configureDependencies(isHeadless);
  await getIt.allReady();
  return;
}

@InjectableInit()
Future<void> configureDependencies([isHeadless = false]) async {
  const env = String.fromEnvironment(ENV, defaultValue: Env.PRODUCTION);
  getIt.registerSingleton<String>(env, instanceName: ENV);
  getIt.registerSingleton<bool>(isHeadless, instanceName: HEADLESS);
  await $initGetIt(getIt, environment: env);
}

@module
abstract class RegisterModule {
  @preResolve
  Future<Prefs> get prefs => Prefs.create();

  @preResolve
  Future<PackageInfo> get packageInfo => PackageInfo.fromPlatform();

  BuildConfig get buildConfig {
    final String? env = getIt<String>(instanceName: 'env');
    String envApiUrl = '';

    if (env == Env.DEVELOPMENT) {
      envApiUrl = String.fromEnvironment('SERVER_URL', defaultValue: 'https://test.couriermarket.com/api');
      return BuildConfig(
        env: Env.DEVELOPMENT,
        apiUrl: envApiUrl,
        apiClientId: "2",
        apiClientSecret: "ajuUe7LUndZjBRQt64rFuPh1TIstbPTxJCkJPq50",
      );
    } else if (env == Env.STAGING) {
      envApiUrl = String.fromEnvironment('SERVER_URL', defaultValue: 'https://test.couriermarket.com/api');
      return BuildConfig(
        env: Env.STAGING,
        apiUrl: envApiUrl,
        apiClientId: "2",
        apiClientSecret: "23uGh8bMDyuBGwujpvtc4yxgRAVNkLzLnBFTsRDcxZ9hqvTCZZ",
      );
    } else {
      envApiUrl = String.fromEnvironment('SERVER_URL', defaultValue: 'https://app.couriermarket.com/api');
      return BuildConfig(
        apiUrl: envApiUrl,
        apiClientId: "2",
        apiClientSecret: "ajuUe7LUndZjBRQt64rFuPh1TIstbPTxJCkJPq50",
      );
    }
  }

  final Router router = Router(authGuard: AuthGuard());
}
