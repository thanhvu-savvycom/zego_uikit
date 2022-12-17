// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

mixin ZegoUIKitRoomAttributesPluginService {
  /// update room property
  Future<ZegoSignalingPluginResult> updateRoomProperty(
    String key,
    String value, {
    bool isForce = false,
    bool isDeleteAfterOwnerLeft = false,
    bool isUpdateOwner = false,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('updateRoomProperty', {
      'key': key,
      'value': value,
      'isForce': isForce,
      'isDeleteAfterOwnerLeft': isDeleteAfterOwnerLeft,
      'isUpdateOwner': isUpdateOwner,
    });

    return ZegoSignalingPluginResult(
      result['errorCode'] as String,
      result['errorMessage'] as String,
      result: result['errorKeys'] as List<String>,
    );
  }

  /// delete room properties
  Future<ZegoSignalingPluginResult> deleteRoomProperties(
    List<String> keys, {
    bool isForce = false,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('deleteRoomProperties', {
      'keys': keys,
      'isForce': isForce,
    });

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
      result: result['errorKeys'] as List<String>,
    );
  }

  /// begin room properties in batch operation
  Future<ZegoSignalingPluginResult> beginRoomPropertiesBatchOperation({
    bool isDeleteAfterOwnerLeft = false,
    bool isForce = false,
    bool isUpdateOwner = false,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('beginRoomPropertiesBatchOperation', {
      'isDeleteAfterOwnerLeft': isDeleteAfterOwnerLeft,
      'isForce': isForce,
      'isUpdateOwner': isUpdateOwner,
    });

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
    );
  }

  /// end room properties in batch operation
  Future<ZegoSignalingPluginResult> endRoomPropertiesBatchOperation() async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('endRoomPropertiesBatchOperation', {});

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
    );
  }

  /// query room properties
  Future<ZegoSignalingPluginResult> queryRoomProperties({
    String nextFlag = '',
    int count = 100,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('queryRoomProperties', {});

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
      result: result['roomAttributes'] as Map<String, String>,
    );
  }

  /// get room properties notifier
  Stream<ZegoSignalingRoomPropertiesData> getRoomPropertiesStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('roomPropertiesStream')
        .map((data) {
      Map<ZegoSignalingRoomAttributesUpdateAction, Map<String, String>>
          propertiesData = {};
      data.forEach((key, value) {
        propertiesData[ZegoSignalingRoomAttributesUpdateAction
            .values[key as int]] = value as Map<String, String>;
      });
      return ZegoSignalingRoomPropertiesData(actionDataMap: propertiesData);
    });
  }

  /// get room batch properties notifier
  Stream<ZegoSignalingRoomBatchPropertiesData> getRoomBatchPropertiesStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('roomBatchPropertiesStream')
        .map((data) {
      Map<ZegoSignalingRoomAttributesUpdateAction, List<Map<String, String>>>
          propertiesData = {};
      data.forEach((key, value) {
        propertiesData[ZegoSignalingRoomAttributesUpdateAction
            .values[key as int]] = value as List<Map<String, String>>;
      });
      return ZegoSignalingRoomBatchPropertiesData(
          actionDataMap: propertiesData);
    });
  }
}
