part of 'zego_uikit_core.dart';

extension ZegoUIKitCorePlugin on ZegoUIKitCore {
  void installPlugins(List<IZegoUIKitPlugin> instances) {
    for (var item in instances) {
      ZegoUIKitPluginType itemType = item.getPluginType();
      if (plugins[itemType] != null) {
        debugPrint(
            "plugin type:$itemType already exists, will update plugin instance");
      }
      plugins[itemType] = item;
      debugPrint("installed $itemType");
    }
  }
}
