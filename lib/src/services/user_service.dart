part of 'uikit_service.dart';

mixin ZegoUserService {
  Future<void> login(String id, String name) async {
    ZegoUIKitCore.shared.login(id, name);
  }

  Future<void> logout() async {
    return await ZegoUIKitCore.shared.logout();
  }

  ZegoUIKitUser getLocalUser() {
    return ZegoUIKitCore.shared.coreData.localUser.toZegoUikitUser();
  }

  List<ZegoUIKitUser> getAllUsers() {
    return [
      ZegoUIKitCore.shared.coreData.localUser.toZegoUikitUser(),
      ...ZegoUIKitCore.shared.coreData.remoteUsersList
          .map((user) => user.toZegoUikitUser())
          .toList()
    ];
  }

  List<ZegoUIKitUser> getRemoteUsers() {
    return ZegoUIKitCore.shared.coreData.remoteUsersList
        .map((user) => user.toZegoUikitUser())
        .toList();
  }

  ZegoUIKitUser? getUser(String userID) {
    if (userID.isEmpty) {
      return null;
    }

    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.toZegoUikitUser();
    } else {
      var queryUser = ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((element) => element.id == userID,
              orElse: () => ZegoUIKitCoreUser.empty())
          .toZegoUikitUser();
      return queryUser.isEmpty() ? null : queryUser;
    }
  }

  ValueNotifier<Map<String, String>> getInRoomUserAttributesNotifier(
      String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.inRoomAttributes;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: () => ZegoUIKitCoreUser.empty())
          .inRoomAttributes;
    }
  }

  Stream<List<ZegoUIKitUser>> getUserListStream() {
    return ZegoUIKitCore.shared.coreData.userListStreamCtrl.stream
        .map((users) => users.map((e) => e.toZegoUikitUser()).toList());
  }

  Stream<List<ZegoUIKitUser>> getUserJoinStream() {
    return ZegoUIKitCore.shared.coreData.userJoinStreamCtrl.stream
        .map((users) => users.map((e) => e.toZegoUikitUser()).toList());
  }

  Stream<List<ZegoUIKitUser>> getUserLeaveStream() {
    return ZegoUIKitCore.shared.coreData.userLeaveStreamCtrl.stream
        .map((users) => users.map((e) => e.toZegoUikitUser()).toList());
  }
}
