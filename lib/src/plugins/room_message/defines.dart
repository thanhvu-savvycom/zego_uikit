class ZegoSignalingInRoomTextMessage {
  int messageID;
  int timestamp;
  int orderKey;
  String senderUserID;
  String text;

  ZegoSignalingInRoomTextMessage({
    required this.messageID,
    required this.timestamp,
    required this.orderKey,
    required this.senderUserID,
    required this.text,
  });
}
