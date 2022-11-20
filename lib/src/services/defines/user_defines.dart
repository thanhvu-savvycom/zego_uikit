// Package imports:
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoUIKitUser {
  String id = '';
  String name = '';

  ZegoUIKitUser.empty();

  bool isEmpty() {
    return id.isEmpty || name.isEmpty;
  }

  ZegoUIKitUser({required this.id, required this.name});

  // internal helper function
  ZegoUser toZegoUser() => ZegoUser(id, name);

  ZegoUIKitUser.fromZego(ZegoUser zegoUser)
      : this(id: zegoUser.userID, name: zegoUser.userName);

  @override
  String toString() {
    return "id:$id, name:$name";
  }
}
