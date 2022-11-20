part of 'uikit_service.dart';

mixin ZegoAudioVideoService {
  void startPlayAllAudioVideo() {
    ZegoUIKitCore.shared.startPlayAllAudioVideo();
  }

  void stopPlayAllAudioVideo() {
    ZegoUIKitCore.shared.stopPlayAllAudioVideo();
  }

  void setAudioOutputToSpeaker(bool isSpeaker) {
    ZegoUIKitCore.shared.setAudioOutputToSpeaker(isSpeaker);
  }

  void turnCameraOn(bool isOn, {String? userID}) {
    ZegoUIKitCore.shared.turnCameraOn(isOn);
  }

  void turnMicrophoneOn(bool enable, {String? userID}) {
    ZegoUIKitCore.shared.turnMicrophoneOn(enable);
  }

  void useFrontFacingCamera(bool isFrontFacing) {
    ZegoUIKitCore.shared.useFrontFacingCamera(isFrontFacing);
  }

  void setVideoMirrorMode(bool isVideoMirror) {
    ZegoUIKitCore.shared.setVideoMirrorMode(isVideoMirror);
  }

  void setAudioConfig() {}

  void setVideoConfig() {}

  ValueNotifier<Widget?> getAudioVideoViewNotifier(String? userID) {
    if (userID == null ||
        userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.view;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: () => ZegoUIKitCoreUser.empty())
          .view;
    }
  }

  ValueNotifier<bool> getCameraStateNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.camera;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: () => ZegoUIKitCoreUser.empty())
          .camera;
    }
  }

  ValueNotifier<bool> getUseFrontFacingCameraStateNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.isFrontFacing;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: () => ZegoUIKitCoreUser.empty())
          .isFrontFacing;
    }
  }

  ValueNotifier<bool> getMicrophoneStateNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.microphone;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: () => ZegoUIKitCoreUser.empty())
          .microphone;
    }
  }

  ValueNotifier<ZegoAudioRoute> getAudioOutputDeviceNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.audioRoute;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: () => ZegoUIKitCoreUser.empty())
          .audioRoute;
    }
  }

  Stream<double> getSoundLevelStream(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.soundLevel.stream;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: () => ZegoUIKitCoreUser.empty())
          .soundLevel
          .stream;
    }
  }

  List<ZegoUIKitUser> getAudioVideoList() {
    return ZegoUIKitCore.shared.coreData
        .getAudioVideoList()
        .map((e) => e.toZegoUikitUser())
        .toList();
  }

  Stream<List<ZegoUIKitUser>> getAudioVideoListStream() {
    return ZegoUIKitCore.shared.coreData.audioVideoListStreamCtrl.stream
        .map((users) => users.map((e) => e.toZegoUikitUser()).toList());
  }

  ValueNotifier<Size> getVideoSizeNotifier(String userID) {
    if (userID == ZegoUIKitCore.shared.coreData.localUser.id) {
      return ZegoUIKitCore.shared.coreData.localUser.viewSize;
    } else {
      return ZegoUIKitCore.shared.coreData.remoteUsersList
          .firstWhere((user) => user.id == userID,
              orElse: () => ZegoUIKitCoreUser.empty())
          .viewSize;
    }
  }

  void updateTextureRendererSize(String? userID, int width, int height) {
    ZegoUIKitCore.shared.updateTextureRendererSize(userID, width, height);
  }

  void updateTextureRendererOrientation(Orientation orientation) {
    ZegoUIKitCore.shared.updateTextureRendererOrientation(orientation);
  }

  void updateAppOrientation(DeviceOrientation orientation) {
    ZegoUIKitCore.shared.updateAppOrientation(orientation);
  }

  void updateVideoViewMode(bool useVideoViewAspectFill) {
    ZegoUIKitCore.shared.updateVideoViewMode(useVideoViewAspectFill);
  }
}
