// Project imports:
import 'package:zego_uikit/src/plugins/defines.dart';
import 'package:zego_uikit/zego_uikit.dart';

mixin ZegoUIKitRoomAttributesPluginService {
  Future<ZegoSignalingPluginResult> setRoomAttributes(
    Map<String, String> roomAttributes, {
    bool isForce = false,
    bool isDeleteAfterOwnerLeft = false,
    bool isUpdateOwner = false,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('setRoomAttributes', {
      'roomAttributes': roomAttributes,
      'isForce': isForce,
      'isDeleteAfterOwnerLeft': isDeleteAfterOwnerLeft,
      'isUpdateOwner': isUpdateOwner,
    });

    return ZegoSignalingPluginResult(
      result['code'] as String,
      result['message'] as String,
      result: result['errorKeys'] as List<String>,
    );
  }

  Future<ZegoSignalingPluginResult> deleteRoomAttributes(
    List<String> keys, {
    bool isForce = false,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('deleteRoomAttributes', {
      'keys': keys,
      'isForce': isForce,
    });

    return ZegoSignalingPluginResult(
      result['code'] as String,
      result['message'] as String,
      result: result['errorKeys'] as List<String>,
    );
  }

  Future<ZegoSignalingPluginResult> beginRoomAttributesBatchOperation({
    bool isForce = false,
    bool isDeleteAfterOwnerLeft = false,
    bool isUpdateOwner = false,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('beginRoomAttributesBatchOperation', {
      'isForce': isForce,
      'isDeleteAfterOwnerLeft': isDeleteAfterOwnerLeft,
      'isUpdateOwner': isUpdateOwner,
    });

    return ZegoSignalingPluginResult(
      result['code'] as String,
      result['message'] as String,
    );
  }

  Future<ZegoSignalingPluginResult> endRoomAttributesBatchOperation() async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('endRoomAttributesBatchOperation', {});

    return ZegoSignalingPluginResult(
      result['code'] as String,
      result['message'] as String,
    );
  }

  Future<ZegoSignalingPluginResult> queryRoomAllAttributes({
    String nextFlag = '',
    int count = 100,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('queryRoomAllAttributes', {});

    return ZegoSignalingPluginResult(
      result['code'] as String,
      result['message'] as String,
      result: result['roomAttributes'] as Map<String, String>,
    );
  }

  Stream<Map> getRoomAttributesStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('roomAttributesStream');
  }

  Stream<Map> getRoomBatchAttributesStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('roomBatchAttributesStream');
  }
}
