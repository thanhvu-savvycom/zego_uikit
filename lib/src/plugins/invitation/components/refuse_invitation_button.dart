// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoRefuseInvitationButton extends StatefulWidget {
  final String inviterID;
  final String? data;

  final String? text;
  final TextStyle? textStyle;
  final ButtonIcon? icon;

  final Size? iconSize;
  final Size? buttonSize;
  final double? iconTextSpacing;
  final bool verticalLayout;

  final Color? clickableTextColor;
  final Color? unclickableTextColor;
  final Color? clickableBackgroundColor;
  final Color? unclickableBackgroundColor;

  ///  You can do what you want after pressed.
  final void Function(String code, String message)? onPressed;

  const ZegoRefuseInvitationButton({
    Key? key,
    required this.inviterID,
    this.data,
    this.text,
    this.textStyle,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.iconTextSpacing,
    this.verticalLayout = true,
    this.onPressed,
    this.clickableTextColor = Colors.black,
    this.unclickableTextColor = Colors.black,
    this.clickableBackgroundColor = Colors.transparent,
    this.unclickableBackgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<ZegoRefuseInvitationButton> createState() =>
      _ZegoRefuseInvitationButtonState();
}

class _ZegoRefuseInvitationButtonState
    extends State<ZegoRefuseInvitationButton> {
  @override
  Widget build(BuildContext context) {
    return ZegoTextIconButton(
      onPressed: onPressed,
      text: widget.text,
      textStyle: widget.textStyle,
      icon: widget.icon,
      iconTextSpacing: widget.iconTextSpacing,
      iconSize: widget.iconSize,
      buttonSize: widget.buttonSize,
      verticalLayout: widget.verticalLayout,
      clickableTextColor: widget.clickableTextColor ?? Colors.white,
      unclickableTextColor: widget.unclickableTextColor,
      clickableBackgroundColor: widget.clickableBackgroundColor,
      unclickableBackgroundColor: widget.unclickableBackgroundColor,
    );
  }

  void onPressed() async {
    var result = await ZegoUIKitSignalingPluginImp.shared
        .refuseInvitation(widget.inviterID, widget.data ?? '');

    if (widget.onPressed != null) {
      widget.onPressed!(result.code, result.message);
    }
  }
}
