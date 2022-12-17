// Dart imports:

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';
import 'invitation/service.dart';
import 'room_message/service.dart';
import 'room_properties/service.dart';
import 'user_attributes/service.dart';

class ZegoUIKitSignalingPluginImpl
    with
        ZegoUIKitInvitationService,
        ZegoUIKitRoomAttributesPluginService,
        ZegoUIKitUserInRoomAttributesPluginService,
        ZegoUIKitRoomMessagePluginService {
  /// single instance
  static final ZegoUIKitSignalingPluginImpl shared =
      ZegoUIKitSignalingPluginImpl._internal();

  /// single instance
  factory ZegoUIKitSignalingPluginImpl() => shared;

  /// single instance
  ZegoUIKitSignalingPluginImpl._internal() {
    WidgetsFlutterBinding.ensureInitialized();
    assert(ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling) != null);
  }

  /// init
  Future<void> init(int appID, {String appSign = ''}) async {
    await ZegoUIKit().getPlugin(ZegoUIKitPluginType.signaling)!.invoke('init', {
      'appID': appID,
      'appSign': appSign,
    });
  }

  /// uninit
  Future<void> uninit() async {
    await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('uninit', {});
  }

  /// login
  Future<void> login(String id, String name) async {
    await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('login', {
      'userID': id,
      'userName': name,
    });
  }

  /// logout
  Future<void> logout() async {
    await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('logout', {});
  }

  /// join room
  Future<ZegoSignalingPluginResult> joinRoom(String roomID,
      {String roomName = ""}) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('joinRoom', {
      'roomID': roomID,
      'roomName': roomName,
    });

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
    );
  }

  /// leave room
  Future<void> leaveRoom() async {
    await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('leaveRoom', {});
  }
}
