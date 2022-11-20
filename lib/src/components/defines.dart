// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

class ButtonIcon {
  Widget? icon;
  Color? backgroundColor;

  ButtonIcon({this.icon, this.backgroundColor});
}

typedef ZegoAvatarBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo);
