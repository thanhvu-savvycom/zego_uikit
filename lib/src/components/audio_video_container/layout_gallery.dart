// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit/src/components/audio_video/audio_video_view.dart';
import 'package:zego_uikit/src/components/audio_video_container/gallery/layout_gallery_last_item.dart';
import 'package:zego_uikit/src/components/defines.dart';
import 'package:zego_uikit/src/services/services.dart';
import 'gallery/grid_layout_delegate.dart';
import 'layout.dart';

/// layout config of gallery
class ZegoLayoutGalleryConfig extends ZegoLayout {
  /// whether to display rounded corners and spacing between views
  bool addBorderRadiusAndSpacingBetweenView;

  ZegoLayoutGalleryConfig({this.addBorderRadiusAndSpacingBetweenView = true})
      : super.internal();
}

/// picture in picture layout
class ZegoLayoutGallery extends StatefulWidget {
  const ZegoLayoutGallery({
    Key? key,
    required this.maxItemCount,
    required this.userList,
    required this.layoutConfig,
    this.backgroundColor = const Color(0xff171821),
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarConfig,
  }) : super(key: key);

  final int maxItemCount;
  final List<ZegoUIKitUser> userList;
  final ZegoLayoutGalleryConfig layoutConfig;

  final Color backgroundColor;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  /// avatar etc.
  final ZegoAvatarConfig? avatarConfig;

  @override
  State<ZegoLayoutGallery> createState() => _ZegoLayoutGalleryState();
}

class _ZegoLayoutGalleryState extends State<ZegoLayoutGallery> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var users = List<ZegoUIKitUser>.from(widget.userList);

    List<ZegoUIKitUser> layoutUsers = [];
    List<ZegoUIKitUser> lastUsers = [];
    if (users.length > widget.maxItemCount) {
      layoutUsers = users.sublist(0, widget.maxItemCount - 1);
      lastUsers = users.sublist(widget.maxItemCount - 1);
    } else {
      layoutUsers = users;
    }

    var layoutItems = layoutUsers.map((user) {
      var audioVideoView = ZegoAudioVideoView(
        user: user,
        backgroundBuilder: widget.backgroundBuilder,
        foregroundBuilder: widget.foregroundBuilder,
        borderRadius: widget.layoutConfig.addBorderRadiusAndSpacingBetweenView
            ? 18.0.w
            : null,
        borderColor: Colors.transparent,
        avatarConfig: widget.avatarConfig,
      );
      return LayoutId(
        id: user.id,
        child: audioVideoView,
      );
    }).toList();
    if (lastUsers.isNotEmpty) {
      layoutItems.add(LayoutId(
        id: "sbs_last_users",
        child: ZegoLayoutGalleryLastItem(
          users: lastUsers,
          backgroundColor: const Color(0xff4A4B4D),
          borderRadius: widget.layoutConfig.addBorderRadiusAndSpacingBetweenView
              ? 18.0.w
              : null,
          borderColor: Colors.transparent,
        ),
      ));
    }

    return Container(
      color: widget.backgroundColor,
      child: CustomMultiChildLayout(
        delegate: GridLayoutDelegate.autoFill(
          autoFillItems: layoutItems,
          columnCount: layoutItems.length > 2 ? 2 : 1,
          lastRowAlignment: GridLayoutAlignment.start,
          itemPadding: widget.layoutConfig.addBorderRadiusAndSpacingBetweenView
              ? Size(10.0.r, 10.0.r)
              : const Size(0, 0),
        ),
        children: layoutItems,
      ),
    );
  }
}
