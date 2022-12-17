// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoSignalingUserInRoomAttributesData {
  Map<String, Map<String, String>> infos;
  ZegoUIKitUser? editor;

  ZegoSignalingUserInRoomAttributesData({
    required this.infos,
    required this.editor,
  });
}
