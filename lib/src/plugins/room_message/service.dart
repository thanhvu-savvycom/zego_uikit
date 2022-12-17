// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

mixin ZegoUIKitRoomMessagePluginService {
  // Future<ZegoSignalingPluginResult> sendInRoomTextMessage(String text) async {
  //   Map result = await ZegoUIKit()
  //       .getPlugin(ZegoUIKitPluginType.signaling)!
  //       .invoke('sendInRoomTextMessage', {
  //     'text': text,
  //   });
  //
  //   return ZegoSignalingPluginResult(
  //     result['errorCode'] as String,
  //     result['errorMessage'] as String,
  //   );
  // }

  /// get in-room text message stream
  Stream<List<ZegoSignalingInRoomTextMessage>> getInRoomTextMessageStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('inRoomTextMessageStream')
        .map((data) {
      List<ZegoSignalingInRoomTextMessage> messages = [];
      for (var messageMap
          in data["messageList"] as List<Map<String, dynamic>>) {
        messages.add(ZegoSignalingInRoomTextMessage(
          messageID: messageMap["messageID"] as int,
          timestamp: messageMap["timestamp"] as int,
          orderKey: messageMap["orderKey"] as int,
          senderUserID: messageMap["senderUserID"] as String,
          text: messageMap["text"] as String,
        ));
      }
      return messages;
    });
  }
}
