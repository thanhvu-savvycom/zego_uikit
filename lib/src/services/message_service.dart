part of 'uikit_service.dart';

mixin ZegoMessageService {
  List<ZegoInRoomMessage> getInRoomMessages() {
    return ZegoUIKitCore.shared.coreMessage.messageList;
  }

  Stream<List<ZegoInRoomMessage>> getInRoomMessageListStream() {
    return ZegoUIKitCore.shared.coreMessage.streamControllerMessageList.stream;
  }

  Stream<ZegoInRoomMessage> getInRoomMessageStream() {
    return ZegoUIKitCore.shared.coreMessage.streamControllerMessage.stream;
  }

  void sendInRoomMessage(String message) {
    return ZegoUIKitCore.shared.coreMessage.sendBroadcastMessage(message);
  }

  void resendInRoomMessage(ZegoInRoomMessage message) {
    return ZegoUIKitCore.shared.coreMessage.resendInRoomMessage(message);
  }
}
