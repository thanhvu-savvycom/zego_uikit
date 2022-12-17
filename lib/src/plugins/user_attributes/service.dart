// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

mixin ZegoUIKitUserInRoomAttributesPluginService {
  /// set users in-room attributes
  Future<ZegoSignalingPluginResult> setUsersInRoomAttributes(
    String key,
    String value,
    List<String> userIDs,
  ) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('setUsersInRoomAttributes', {
      'key': key,
      'value': value,
      'userIDs': userIDs,
    });

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
      result: result['errorUserList'] as List<String>,
    );
  }

  /// query user in-room attributes
  Future<ZegoSignalingPluginResult> queryUsersInRoomAttributes({
    String nextFlag = '',
    int count = 100,
  }) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('queryUsersInRoomAttributes', {
      'nextFlag': nextFlag,
      'count': count,
    });

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
      result: result['infos'] as Map<String, Map<String, String>>,
    );
  }

  /// get users in-room attributes notifier
  Stream<ZegoSignalingUserInRoomAttributesData>
      getUsersInRoomAttributesStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('usersInRoomAttributes')
        .map((data) {
      return ZegoSignalingUserInRoomAttributesData(
        editor: data["editor"] as ZegoUIKitUser?,
        infos: data["infos"] as Map<String, Map<String, String>>,
      );
    });
  }
}
