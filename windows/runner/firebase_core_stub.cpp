#include <firebase_core/firebase_core_plugin_c_api.h>

void FirebaseCorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  (void)registrar;
}

void RegisterFlutterFirebasePlugin(
    const std::string& channel_name, FlutterFirebasePlugin* plugin) {
  (void)channel_name;
  (void)plugin;
}
