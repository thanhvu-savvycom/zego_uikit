// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:wakelock/wakelock.dart';

// Project imports:
import 'package:zego_uikit/src/services/services.dart';

// Project imports:
part 'zego_uikit_core_defines.dart';

part 'zego_uikit_core_event.dart';

part 'zego_uikit_core_data.dart';

part 'zego_uikit_core_message.dart';

part 'zego_uikit_core_plugin.dart';

class ZegoUIKitCore with ZegoUIKitCoreEvent {
  ZegoUIKitCore._internal();

  static final ZegoUIKitCore shared = ZegoUIKitCore._internal();

  final ZegoUIKitCoreData coreData = ZegoUIKitCoreData();
  final ZegoUIKitCoreMessage coreMessage = ZegoUIKitCoreMessage();

  Map<ZegoUIKitPluginType, IZegoUIKitPlugin> plugins = {};

  bool isInit = false;
  bool isNeedDisableWakelock = false;

  Future<String> getZegoUIKitVersion() async {
    String expressVersion = await ZegoExpressEngine.getVersion();
    String zegoUIKitVersion = 'zego_uikit:1.7.0; ';
    return zegoUIKitVersion + 'zego_express:$expressVersion';
  }

  Future<void> init({
    required int appID,
    String appSign = '',
    ZegoScenario scenario = ZegoScenario.Communication,
    String? tokenServerUrl,
  }) async {
    if (isInit) {
      debugPrint("[core] core had init");
      return;
    }

    isInit = true;

    ZegoEngineProfile profile =
        ZegoEngineProfile(appID, scenario, appSign: appSign);
    if (kIsWeb) {
      profile.appSign = null;
      profile.enablePlatformView = true;
    }
    initEventHandle();

    await ZegoExpressEngine.createEngineWithProfile(profile);

    if (!kIsWeb) {
      ZegoExpressEngine.setEngineConfig(ZegoEngineConfig(advancedConfig: {
        'notify_remote_device_unknown_status': 'true',
        'notify_remote_device_init_status': 'true',
      }));

      var initAudioRoute = await ZegoExpressEngine.instance.getAudioRouteType();
      coreData.localUser.audioRoute.value = initAudioRoute;
      coreData.localUser.lastAudioRoute = initAudioRoute;
    }
  }

  Future<void> uninit() async {
    if (!isInit) {
      debugPrint("[core] core is not init");
      return;
    }

    isInit = false;

    uninitEventHandle();
    clear();

    await ZegoExpressEngine.destroyEngine();
  }

  void clear() {
    coreData.clear();
    coreMessage.clear();
  }

  @override
  void uninitEventHandle() {}

  Future<void> login(String id, String name) async {
    coreData.login(id, name);
  }

  Future<void> logout() async {
    coreData.logout();
  }

  Future<ZegoRoomLoginResult> joinRoom(String roomID,
      {String token = ''}) async {
    if (kIsWeb) {
      assert(token.isNotEmpty);
    }

    debugPrint("[core] join room, room id:$roomID, token:$token");

    clear();
    coreData.setRoom(roomID);

    Future<bool> originWakelockEnabledF = Wakelock.enabled;

    ZegoRoomLoginResult joinRoomResult =
        await ZegoExpressEngine.instance.loginRoom(
      roomID,
      coreData.localUser.toZegoUser(),
      config: ZegoRoomConfig(0, true, token),
    );

    if (joinRoomResult.errorCode == 0) {
      coreData.startPublishOrNot();
      bool originWakelockEnabled = await originWakelockEnabledF;
      if (originWakelockEnabled) {
        isNeedDisableWakelock = false;
      } else {
        isNeedDisableWakelock = true;
        Wakelock.enable();
      }
      if (!kIsWeb) ZegoExpressEngine.instance.startSoundLevelMonitor();
    } else if (joinRoomResult.errorCode == ZegoErrorCode.RoomCountExceed) {
      debugPrint("[core] room count exceed");

      await leaveRoom();
      return await joinRoom(roomID, token: token);
    } else {
      log("joinRoom failed: ${joinRoomResult.errorCode}, ${joinRoomResult.extendedData.toString()}");
    }

    return joinRoomResult;
  }

  Future<ZegoRoomLogoutResult> leaveRoom() async {
    if (isNeedDisableWakelock) {
      Wakelock.disable();
    }

    clear();

    if (!kIsWeb) {
      await ZegoExpressEngine.instance.stopSoundLevelMonitor();
    }

    ZegoRoomLogoutResult leaveResult =
        await ZegoExpressEngine.instance.logoutRoom();
    if (leaveResult.errorCode != 0) {
      log("leaveRoom failed: ${leaveResult.errorCode}, ${leaveResult.extendedData.toString()}");
    }

    return leaveResult;
  }

  Future<bool> updateRoomProperty(String key, String value) async {
    return ZegoUIKitCore.shared.updateRoomProperties({key: value});
  }

  Future<bool> updateRoomProperties(Map<String, String> properties) async {
    debugPrint("[core] set room property: $properties");

    if (coreData.room.propertiesAPIRequesting) {
      properties.forEach((key, value) {
        coreData.room.pendingProperties[key] = value;
      });
      debugPrint(
          "[core] room property is updating, pending: ${coreData.room.pendingProperties}");
      return false;
    }

    if (!isInit) {
      debugPrint("[core] core had not init");
      return false;
    }

    if (coreData.room.id.isEmpty) {
      debugPrint("[core] room is not login");
      return false;
    }

    var localUser = ZegoUIKit().getLocalUser();

    var isAllPropertiesSame = coreData.room.properties.isNotEmpty;
    properties.forEach((key, value) {
      if (coreData.room.properties.containsKey(key) &&
          coreData.room.properties[key]!.value == value) {
        debugPrint(
            "[core] key exist and value is same, ${coreData.room.properties.toString()}");
        isAllPropertiesSame = false;
      }
    });
    if (isAllPropertiesSame) {
      debugPrint("[core] all key exist and value is same");
      // return true;
    }

    Map<String, RoomProperty?> oldProperties = {};
    properties.forEach((key, value) {
      if (coreData.room.properties.containsKey(key)) {
        oldProperties[key] =
            RoomProperty.copyFrom(coreData.room.properties[key]!);
        oldProperties[key]!.updateUserID = localUser.id;
      }
    });

    /// local update
    properties.forEach((key, value) {
      if (coreData.room.properties.containsKey(key)) {
        coreData.room.properties[key]!.oldValue =
            coreData.room.properties[key]!.value;
        coreData.room.properties[key]!.value = value;
        coreData.room.properties[key]!.updateTime =
            DateTime.now().millisecondsSinceEpoch;
      } else {
        coreData.room.properties[key] = RoomProperty(
          key,
          value,
          DateTime.now().millisecondsSinceEpoch,
          localUser.id,
        );
      }
    });

    /// server update
    Map<String, String> extraInfoMap = {};
    coreData.room.properties.forEach((key, value) {
      extraInfoMap[key] = value.value;
    });
    var extraInfo = const JsonEncoder().convert(extraInfoMap);
    // if (extraInfo.length > 128) {
    //   debugPrint("[core] value length out of limit");
    //   return false;
    // }
    debugPrint("[core] call set room extra info, $extraInfo");

    debugPrint("[core] call setRoomExtraInfo");
    coreData.room.propertiesAPIRequesting = true;
    return ZegoExpressEngine.instance
        .setRoomExtraInfo(coreData.room.id, "extra_info", extraInfo)
        .then((ZegoRoomSetRoomExtraInfoResult result) {
      debugPrint("[core] setRoomExtraInfo finished");
      if (0 == result.errorCode) {
        properties.forEach((key, value) {
          var updatedProperty = coreData.room.properties[key]!;
          coreData.room.propertyUpdateStream.add(updatedProperty);
          coreData.room.propertiesUpdatedStream.add({key: updatedProperty});
        });
      } else {
        properties.forEach((key, value) {
          if (coreData.room.properties.containsKey(key)) {
            coreData.room.properties[key]!.copyFrom(oldProperties[key]!);
          }
        });
        debugPrint(
            "[core] fail to set room properties:$properties! error code:${result.errorCode}");
      }

      coreData.room.propertiesAPIRequesting = false;
      if (coreData.room.pendingProperties.isNotEmpty) {
        var pendingProperties =
            Map<String, String>.from(coreData.room.pendingProperties);
        coreData.room.pendingProperties.clear();
        debugPrint("[core] update pending properties:$pendingProperties");
        updateRoomProperties(pendingProperties);
      }

      return 0 != result.errorCode;
    });
  }

  Future<bool> sendCustomCommand(Map<String, String> commands) async {
    var command = const JsonEncoder().convert(commands);
    return await ZegoExpressEngine.instance
        .sendCustomCommand(
            coreData.room.id,
            command,
            coreData.remoteUsersList
                .map((ZegoUIKitCoreUser user) => ZegoUser(user.id, user.name))
                .toList())
        .then(
      (ZegoIMSendCustomCommandResult result) {
        if (0 != result.errorCode) {
          debugPrint(
              "fail to send custom command end room, error code:${result.errorCode}");
        }

        return 0 == result.errorCode;
      },
    );
  }

  void useFrontFacingCamera(bool isFrontFacing) {
    if (kIsWeb) {
      return;
    }
    if (isFrontFacing == coreData.localUser.isFrontFacing.value) {
      return;
    }

    ZegoExpressEngine.instance.useFrontCamera(isFrontFacing);
    coreData.localUser.isFrontFacing.value = isFrontFacing;
  }

  void setVideoMirrorMode(bool isVideoMirror) {
    ZegoExpressEngine.instance.setVideoMirrorMode(
      isVideoMirror
          ? ZegoVideoMirrorMode.BothMirror
          : ZegoVideoMirrorMode.NoMirror,
    );
  }

  void startPlayAllAudioVideo() {
    coreData.muteAllPlayStreamAudioVideo(false);
  }

  void stopPlayAllAudioVideo() {
    coreData.muteAllPlayStreamAudioVideo(true);
  }

  void setAudioOutputToSpeaker(bool useSpeaker) {
    if (!isInit) {
      debugPrint("[core] set audio output to speaker, core had not init");
      return;
    }

    if (kIsWeb) {
      return;
    }
    if (useSpeaker ==
        (coreData.localUser.audioRoute.value == ZegoAudioRoute.Speaker)) {
      return;
    }

    ZegoExpressEngine.instance.setAudioRouteToSpeaker(useSpeaker);

    // TODO: use sdk callback to update audioRoute
    if (useSpeaker) {
      coreData.localUser.lastAudioRoute = coreData.localUser.audioRoute.value;
      coreData.localUser.audioRoute.value = ZegoAudioRoute.Speaker;
    } else {
      coreData.localUser.audioRoute.value = coreData.localUser.lastAudioRoute;
    }
  }

  void turnCameraOn(bool isOn) {
    debugPrint("[core] turn on camera $isOn");

    if (!isInit) {
      debugPrint("[core] turn on camera, core had not init");
      return;
    }

    if (isOn == coreData.localUser.camera.value) {
      debugPrint("[core] turn on camera, value is equal");
      return;
    }

    if (isOn) {
      coreData.startPreview();
    } else {
      coreData.stopPreview();
    }

    if (kIsWeb) {
      ZegoExpressEngine.instance.mutePublishStreamVideo(!isOn);
    } else {
      ZegoExpressEngine.instance.enableCamera(isOn);
    }

    coreData.localUser.camera.value = isOn;

    coreData.startPublishOrNot();
  }

  void turnMicrophoneOn(bool isOn) {
    debugPrint("[core] turn on microphone $isOn");

    if (!isInit) {
      debugPrint("[core] turn on microphone, core had not init");
      return;
    }

    if (isOn == coreData.localUser.microphone.value) {
      debugPrint("[core] turn on microphone, value is equal");
      return;
    }

    if (kIsWeb) {
      ZegoExpressEngine.instance.mutePublishStreamAudio(!isOn);
    } else {
      ZegoExpressEngine.instance.muteMicrophone(!isOn);
    }

    coreData.localUser.microphone.value = isOn;
    coreData.startPublishOrNot();
  }

  void updateTextureRendererOrientation(Orientation orientation) {
    switch (orientation) {
      case Orientation.portrait:
        ZegoExpressEngine.instance
            .setAppOrientation(DeviceOrientation.portraitUp);
        break;
      case Orientation.landscape:
        ZegoExpressEngine.instance
            .setAppOrientation(DeviceOrientation.landscapeLeft);
        break;
    }
  }

  void updateTextureRendererSize(String? targetUserID, int w, int h) {
    if (kIsWeb) {
      return;
    }

    int textureID = -1;
    int oldWidth = w;
    int oldHeight = h;
    if (targetUserID == null ||
        targetUserID == ZegoUIKitCore.shared.coreData.localUser.id) {
      if (ZegoUIKitCore.shared.coreData.localUser.viewID == -1) {
        debugPrint("[core] user id:$targetUserID's texture id is -1");
        return;
      }

      textureID = ZegoUIKitCore.shared.coreData.localUser.viewID;
      oldWidth = ZegoUIKitCore.shared.coreData.localUser.textureWidth;
      oldHeight = ZegoUIKitCore.shared.coreData.localUser.textureHeight;
      if (oldWidth == w && oldHeight == h) {
        debugPrint("[core] user id:$targetUserID's size is equal");
        return;
      }
      ZegoUIKitCore.shared.coreData.localUser.textureWidth = w;
      ZegoUIKitCore.shared.coreData.localUser.textureHeight = h;
    } else {
      var targetUser = ZegoUIKitCore.shared.coreData.remoteUsersList.firstWhere(
          (user) => targetUserID == user.id,
          orElse: () => ZegoUIKitCoreUser.empty());
      textureID = targetUser.viewID;
      if (textureID == -1) {
        debugPrint("[core] user id:$targetUserID's texture id is -1");
        return;
      }
      oldWidth = targetUser.textureWidth;
      oldHeight = targetUser.textureHeight;
      if (oldWidth == w && oldHeight == h) {
        debugPrint("[core] user id:$targetUserID's size is equal");
        return;
      }
      targetUser.textureWidth = w;
      targetUser.textureHeight = h;
    }

    // ZegoExpressEngine.instance.updateTextureRendererSize(textureID, w, h);
  }

  void setVideoConfig(ZegoUIKitVideoConfig config) {
    if (coreData.videoConfig.needUpdateVideoConfig(config)) {
      ZegoVideoConfig zegoVideoConfig = config.toZegoVideoConfig();
      ZegoExpressEngine.instance.setVideoConfig(zegoVideoConfig);
      coreData.localUser.viewSize.value = Size(
          zegoVideoConfig.captureWidth.toDouble(),
          zegoVideoConfig.captureHeight.toDouble());
    }
    if (coreData.videoConfig.needUpdateOrientation(config)) {
      ZegoExpressEngine.instance.setAppOrientation(config.orientation);
    }

    coreData.videoConfig = config;
  }

  void updateAppOrientation(DeviceOrientation orientation) {
    if (coreData.videoConfig.orientation == orientation) {
      debugPrint("[core] app orientation is equal");
      return;
    } else {
      setVideoConfig(coreData.videoConfig.copyWith(orientation: orientation));
    }
  }

  void updateVideoViewMode(bool useVideoViewAspectFill) {
    if (coreData.videoConfig.useVideoViewAspectFill == useVideoViewAspectFill) {
      debugPrint("[core] video view mode is equal");
      return;
    } else {
      coreData.videoConfig.useVideoViewAspectFill = useVideoViewAspectFill;
      // TODO: need re preview, and re playStream
    }
  }
}

extension ZegoUIKitCoreBaseBeauty on ZegoUIKitCore {
  Future<void> enableBeauty(bool isOn) async {
    ZegoExpressEngine.instance.enableEffectsBeauty(isOn);
  }

  Future<void> startEffectsEnv() async {
    await ZegoExpressEngine.instance.startEffectsEnv();
  }

  Future<void> stopEffectsEnv() async {
    await ZegoExpressEngine.instance.stopEffectsEnv();
  }
}
