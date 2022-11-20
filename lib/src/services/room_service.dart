part of 'uikit_service.dart';

mixin ZegoRoomService {
  Future<ZegoRoomLoginResult> joinRoom(String roomID,
      {String token = ''}) async {
    return await ZegoUIKitCore.shared.joinRoom(roomID, token: token);
  }

  Future<ZegoRoomLogoutResult> leaveRoom() async {
    return await ZegoUIKitCore.shared.leaveRoom();
  }

  ZegoUIKitRoom getRoom() {
    return ZegoUIKitCore.shared.coreData.room.toUIKitRoom();
  }

  ValueNotifier<ZegoUIKitRoomState> getRoomStateStream() {
    return ZegoUIKitCore.shared.coreData.room.state;
  }

  Future<bool> updateRoomProperty(String key, String value) async {
    return ZegoUIKitCore.shared.updateRoomProperty(key, value);
  }

  Future<bool> updateRoomProperties(Map<String, String> properties) async {
    return ZegoUIKitCore.shared
        .updateRoomProperties(Map<String, String>.from(properties));
  }

  Map<String, RoomProperty> getRoomProperties() {
    return Map<String, RoomProperty>.from(
        ZegoUIKitCore.shared.coreData.room.properties);
  }

  /// only notify the property which changed
  /// you can get full properties by getRoomProperties() function
  Stream<RoomProperty> getRoomPropertyStream() {
    return ZegoUIKitCore.shared.coreData.room.propertyUpdateStream.stream;
  }

  /// only notify the properties which changed
  /// you can get full properties by getRoomProperties() function
  Stream<Map<String, RoomProperty>> getRoomPropertiesStream() {
    return ZegoUIKitCore.shared.coreData.room.propertiesUpdatedStream.stream;
  }

  Stream<ZegoNetworkMode> getNetworkModeStream() {
    return ZegoUIKitCore.shared.coreData.networkModeStreamCtrl.stream;
  }
}
