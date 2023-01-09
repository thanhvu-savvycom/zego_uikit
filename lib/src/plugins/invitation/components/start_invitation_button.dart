// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoStartInvitationButton extends StatefulWidget {
  final int invitationType;
  final List<String> invitees;
  final String data;
  final int timeoutSeconds;

  final String? text;
  final TextStyle? textStyle;
  final ButtonIcon? icon;

  final Size? iconSize;
  final Size? buttonSize;
  final double? iconTextSpacing;
  final bool verticalLayout;

  /// start invitation if return true
  /// false will do nothing
  final bool Function()? onWillPressed;

  ///  You can do what you want after pressed.
  final void Function(String code, String message, List<String>)? onPressed;

  final Color? clickableTextColor;
  final Color? unclickableTextColor;
  final Color? clickableBackgroundColor;
  final Color? unclickableBackgroundColor;

  const ZegoStartInvitationButton({
    Key? key,
    required this.invitationType,
    required this.invitees,
    required this.data,
    this.timeoutSeconds = 60,
    this.text,
    this.textStyle,
    this.icon,
    this.iconSize,
    this.iconTextSpacing,
    this.verticalLayout = true,
    this.buttonSize,
    this.onWillPressed,
    this.onPressed,
    this.clickableTextColor = Colors.black,
    this.unclickableTextColor = Colors.black,
    this.clickableBackgroundColor = Colors.transparent,
    this.unclickableBackgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<ZegoStartInvitationButton> createState() => _ZegoStartInvitationButtonState();
}

class _ZegoStartInvitationButtonState extends State<ZegoStartInvitationButton> {
  @override
  Widget build(BuildContext context) {
    return ZegoTextIconButton(
      onPressed: widget.invitees.isEmpty ? null : onPressed,
      text: widget.text,
      textStyle: widget.textStyle,
      icon: widget.icon,
      iconTextSpacing: widget.iconTextSpacing,
      iconSize: widget.iconSize,
      verticalLayout: widget.verticalLayout,
      clickableTextColor: widget.clickableTextColor,
      unclickableTextColor: widget.unclickableTextColor,
      clickableBackgroundColor: widget.clickableBackgroundColor,
      unclickableBackgroundColor: widget.unclickableBackgroundColor,
    );
  }

  void onPressed() async {
    var canSendInvitation = widget.onWillPressed?.call() ?? true;
    if (!canSendInvitation) {
      return;
    }

    ZegoUIKitSignalingPluginImpl? signalingPlugin;
    try {
      signalingPlugin = ZegoUIKit().getSignalingPlugin();
      var result = await signalingPlugin?.sendInvitation(
        ZegoUIKit().getLocalUser().name,
        widget.invitees,
        widget.timeoutSeconds,
        widget.invitationType,
        widget.data,
      );

      if (widget.onPressed != null) {
        widget.onPressed!(result?.code ?? "", result?.message ?? "", result?.result as List<String>? ?? []);
      }
    } catch (e) {
      print(e.toString());
      widget.onPressed!("", "", []);
    }
  }
}
