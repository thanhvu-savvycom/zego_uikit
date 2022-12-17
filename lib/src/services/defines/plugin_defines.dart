enum ZegoUIKitPluginType {
  signaling, // zim, fcm
  beauty, // effects or avatar
  whiteboard, // superboard
}

enum PluginConnectionState { disconnected, connecting, connected, reconnecting }

enum PluginRoomState { disconnected, connecting, connected }

abstract class IZegoUIKitPlugin {
  ZegoUIKitPluginType getPluginType();

  Future<String> getVersion();

  Future<Map> invoke(String method, Map params);

  Stream<Map> getEventStream(String name);
}
