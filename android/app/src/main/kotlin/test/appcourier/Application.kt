package test.appcourier

import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.packageinfo.PackageInfoPlugin
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import io.flutter.view.FlutterMain
import rekab.app.background_locator.IsolateHolderService

class Application : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
//        IsolateHolderService.setPluginRegistrant(this)
        FlutterMain.startInitialization(this)
    }

    override fun registerWith(registry: PluginRegistry?) {
        if (registry == null) return;
        if (!registry.hasPlugin("io.flutter.plugins.pathprovider")) {
            PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider"))
        }
        if (!registry.hasPlugin("io.flutter.plugins.packageinfo")) {
            PackageInfoPlugin.registerWith(registry.registrarFor("io.flutter.plugins.packageinfo"))
        }
        if (!registry.hasPlugin("io.flutter.plugins.sharedpreferences")) {
            SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences"))
        }
    }
}