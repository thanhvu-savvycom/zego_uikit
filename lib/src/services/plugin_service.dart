part of 'uikit_service.dart';

// see IZegoUIKitPlugin
mixin ZegoPluginService {
  /// install plugins
  void installPlugins(List<IZegoUIKitPlugin> plugins) {
    ZegoUIKitCore.shared.installPlugins(plugins);
  }

  /// get plugin object
  IZegoUIKitPlugin? getPlugin(ZegoUIKitPluginType type) {
    debugPrint('getPlugin: $type');
    return ZegoUIKitCore.shared.plugins[type];
  }
}
