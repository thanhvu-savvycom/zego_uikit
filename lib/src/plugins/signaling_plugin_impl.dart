// Dart imports:

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';
import 'defines.dart';
import 'invitation/service.dart';
import 'room_attributes/service.dart';
import 'user_attributes/service.dart';

class ZegoUIKitSignalingPluginImp
    with
        ZegoUIKitInvitationService,
        ZegoUIKitRoomAttributesPluginService,
        ZegoUIKitUserInRoomAttributesPluginService {
  static final ZegoUIKitSignalingPluginImp shared =
      ZegoUIKitSignalingPluginImp._internal();

  factory ZegoUIKitSignalingPluginImp() => shared;

  ZegoUIKitSignalingPluginImp._internal() {
    WidgetsFlutterBinding.ensureInitialized();
    assert(ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling) != null);
  }

  Future<void> init(int appID, {String appSign = ''}) async {
    await ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)!.invoke('init', {
      'appID': appID,
      'appSign': appSign,
    });
  }

  Future<void> uninit() async {
    await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('uninit', {});
  }

  Future<void> login(String id, String name) async {
    await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('login', {
      'userID': id,
      'userName': name,
    });
  }

  Future<void> logout() async {
    await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('logout', {});
  }

  Future<ZegoSignalingPluginResult> joinRoom(String roomID,
      {String roomName = ""}) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('joinRoom', {
      'roomID': roomID,
      'roomName': roomName,
    });

    return ZegoSignalingPluginResult(
      result['code'] as String,
      result['message'] as String,
    );
  }

  Future<void> leaveRoom() async {
    await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('leaveRoom', {});
  }
}
