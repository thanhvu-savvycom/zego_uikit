// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:native_device_orientation/native_device_orientation.dart';

// Project imports:
import 'package:zego_uikit/src/components/internal/internal.dart';
import 'package:zego_uikit/src/services/services.dart';

/// type of audio video view foreground builder
typedef ZegoAudioVideoViewForegroundBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo);

/// type of audio video view background builder
typedef ZegoAudioVideoViewBackgroundBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo);

/// sort
typedef ZegoAudioVideoViewSorter = List<ZegoUIKitUser> Function(
    List<ZegoUIKitUser>);

/// display user audio and video information,
/// and z order of widget(from bottom to top) is:
/// 1. background view
/// 2. video view
/// 3. foreground view
class ZegoAudioVideoView extends StatefulWidget {
  const ZegoAudioVideoView({
    Key? key,
    required this.user,
    this.backgroundBuilder,
    this.foregroundBuilder,
    this.borderRadius,
    this.borderColor = const Color(0xffA4A4A4),
    this.extraInfo = const {},
  }) : super(key: key);

  final ZegoUIKitUser? user;

  /// foreground builder, you can display something you want on top of the view,
  /// foreground will always show
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// background builder, you can display something when user close camera
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  final double? borderRadius;
  final Color borderColor;
  final Map extraInfo;

  @override
  State<ZegoAudioVideoView> createState() => _ZegoAudioVideoViewState();
}

class _ZegoAudioVideoViewState extends State<ZegoAudioVideoView> {
  @override
  Widget build(BuildContext context) {
    return circleBorder(
      child: Stack(
        children: [
          background(),
          videoView(),
          foreground(),
        ],
      ),
    );
  }

  Widget videoView() {
    if (widget.user == null) {
      return Container(color: Colors.transparent);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getCameraStateNotifier(widget.user!.id),
      builder: (context, isCameraOn, _) {
        if (!isCameraOn) {
          /// hide video view when use close camera
          return Container(color: Colors.transparent);
        }

        return SizedBox.expand(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ValueListenableBuilder<Widget?>(
                valueListenable:
                    ZegoUIKit().getAudioVideoViewNotifier(widget.user!.id),
                builder: (context, userView, _) {
                  if (userView == null) {
                    /// hide video view when use not found
                    return Container(color: Colors.transparent);
                  }

                  return StreamBuilder(
                    stream: NativeDeviceOrientationCommunicator()
                        .onOrientationChanged(),
                    builder: (context,
                        AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
                      if (asyncResult.hasData) {
                        /// Do not update ui when ui is building !!!
                        /// use postFrameCallback to update videoSize
                        WidgetsBinding.instance?.addPostFrameCallback((_) {
                          ///  notify sdk to update video render orientation
                          ZegoUIKit().updateAppOrientation(
                            deviceOrientationMap(asyncResult.data!),
                          );
                        });
                      }

                      ///  notify sdk to update texture render size
                      ZegoUIKit().updateTextureRendererSize(
                        widget.user!.id,
                        constraints.maxWidth.toInt(),
                        constraints.maxHeight.toInt(),
                      );
                      return userView;
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget background() {
    if (widget.backgroundBuilder != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return widget.backgroundBuilder!.call(
            context,
            Size(constraints.maxWidth, constraints.maxHeight),
            widget.user,
            widget.extraInfo,
          );
        },
      );
    }

    return Container(color: Colors.transparent);
  }

  Widget foreground() {
    if (widget.foregroundBuilder != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return widget.foregroundBuilder!.call(
            context,
            Size(constraints.maxWidth, constraints.maxHeight),
            widget.user,
            widget.extraInfo,
          );
        },
      );
    }

    return Container(color: Colors.transparent);
  }

  Widget circleBorder({required Widget child}) {
    if (widget.borderRadius == null) {
      return child;
    }

    BoxDecoration decoration = BoxDecoration(
      border: Border.all(color: widget.borderColor, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
    );

    return Container(
      decoration: decoration,
      child: PhysicalModel(
        color: widget.borderColor,
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
        clipBehavior: Clip.antiAlias,
        elevation: 6.0,
        shadowColor: widget.borderColor.withOpacity(0.3),
        child: child,
      ),
    );
  }
}
