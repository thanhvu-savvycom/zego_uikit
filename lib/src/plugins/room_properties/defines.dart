/// Room attributes update action.
///
/// Description: Room attributes update action.
enum ZegoSignalingRoomAttributesUpdateAction {
  /// Set action.
  set,

  /// Delete action.
  delete
}

class ZegoSignalingRoomPropertiesData {
  Map<ZegoSignalingRoomAttributesUpdateAction, Map<String, String>>
      actionDataMap;

  ZegoSignalingRoomPropertiesData({required this.actionDataMap});
}

class ZegoSignalingRoomBatchPropertiesData {
  Map<ZegoSignalingRoomAttributesUpdateAction, List<Map<String, String>>>
      actionDataMap;

  ZegoSignalingRoomBatchPropertiesData({required this.actionDataMap});
}
