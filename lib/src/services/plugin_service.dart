part of 'uikit_service.dart';

// see IZegoUIKitPlugin
mixin ZegoPluginService {
  void installPlugins(List<IZegoUIKitPlugin> plugins) {
    ZegoUIKitCore.shared.installPlugins(plugins);
  }

  IZegoUIKitPlugin? getPlugin(ZegoUIKitPluginType type) {
    debugPrint('getPlugin: $type');
    return ZegoUIKitCore.shared.plugins[type];
  }
}
