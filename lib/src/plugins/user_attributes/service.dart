// Project imports:
import 'package:zego_uikit/src/plugins/defines.dart';
import 'package:zego_uikit/zego_uikit.dart';

mixin ZegoUIKitUserInRoomAttributesPluginService {
  Future<ZegoSignalingPluginResult> setUsersInRoomAttributes(
    Map<String, String> attributes,
    List<String> userIDs,
  ) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('setUsersInRoomAttributes', {
      'attributes': attributes,
      'userIDs': userIDs,
    });

    return ZegoSignalingPluginResult(
      result['code'] as String,
      result['message'] as String,
      result: result['errorUserList'] as List<String>,
    );
  }

  Future<ZegoSignalingPluginResult> queryUsersInRoomAttributesList({
    String nextFlag = '',
    int count = 100,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('queryUsersInRoomAttributesList', {
      'nextFlag': nextFlag,
      'count': count,
    });

    return ZegoSignalingPluginResult(
      result['code'] as String,
      result['message'] as String,
      result: result['infos'] as Map<String, Map<String, String>>,
    );
  }

  Stream<Map> getUsersInRoomAttributesStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('usersInRoomAttributes');
  }
}
