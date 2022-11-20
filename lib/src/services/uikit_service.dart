// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Project imports:
import 'defines/defines.dart';
import 'internal/internal.dart';

part 'room_service.dart';

part 'message_service.dart';

part 'user_service.dart';

part 'audio_video_service.dart';

part 'effect_service.dart';

part 'plugin_service.dart';

class ZegoUIKit
    with
        ZegoAudioVideoService,
        ZegoRoomService,
        ZegoUserService,
        ZegoMessageService,
        ZegoEffectService,
        ZegoPluginService {
  ZegoUIKit._internal() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  factory ZegoUIKit() => instance;
  static final ZegoUIKit instance = ZegoUIKit._internal();

  Future<String> getZegoUIKitVersion() async {
    return await ZegoUIKitCore.shared.getZegoUIKitVersion();
  }

  Future<void> init(
      {required int appID,
      String appSign = '',
      ZegoScenario scenario = ZegoScenario.Communication,
      String tokenServerUrl = ''}) async {
    return await ZegoUIKitCore.shared.init(
        appID: appID,
        appSign: appSign,
        scenario: scenario,
        tokenServerUrl: tokenServerUrl);
  }

  Future<void> uninit() async {
    return await ZegoUIKitCore.shared.uninit();
  }
}
