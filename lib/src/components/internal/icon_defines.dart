// Flutter imports:
import 'package:flutter/material.dart';

const controlBarButtonBackgroundColor = Colors.white;
final controlBarButtonCheckedBackgroundColor =
    const Color(0xFF1D1D1D).withOpacity(0.75);

class UIKitImage {
  static Image asset(String name) {
    return Image.asset(name, package: "zego_uikit");
  }
}

class StyleIconUrls {
  static const String iconS1ControlBarCameraNormal =
      'assets/icons/video_camera_on.png';
  static const String iconS1ControlBarCameraOff =
      'assets/icons/video_camera_off.png';
  static const String iconS1ControlBarFlipCamera =
      'assets/icons/flip_camera.png';
  static const String iconS1ControlBarMicrophoneNormal =
      'assets/icons/mic_on.png';
  static const String iconS1ControlBarMicrophoneOff =
      'assets/icons/mic_off.png';

  static const String iconS1ControlBarEnd = 'assets/icons/end.png';

  static const String iconS1ControlBarSpeakerNormal =
      'assets/icons/speaker_on.png';
  static const String iconS1ControlBarSpeakerOff =
      'assets/icons/speaker_off.png';
  static const String iconS1ControlBarSpeakerBluetooth =
      'assets/icons/s1_ctrl_bar_speaker_bluetooth.png';

  static const String iconS1ControlBarMore =
      'assets/icons/s1_ctrl_bar_more_normal.png';
  static const String iconS1ControlBarMoreChecked =
      'assets/icons/s1_ctrl_bar_more_checked.png';

  static const String iconVideoViewCameraOff =
      'assets/icons/video_camera_off.png';
  static const String iconVideoViewCameraOn =
      'assets/icons/video_camera_on.png';
  static const String iconVideoViewMicrophoneOff =
      'assets/icons/mic_off.png';
  static const String iconVideoViewMicrophoneOn =
      'assets/icons/mic_on.png';
  static const String iconVideoViewMicrophoneSpeaking =
      'assets/icons/video_view_mic_speaking.png';
  static const String iconVideoViewWifi = 'assets/icons/video_view_wifi.png';

  static const String inviteVoice = 'assets/images/invite_voice.png';
  static const String inviteVideo = 'assets/images/invite_video.png';
  static const String inviteReject = 'assets/images/invite_reject.png';

  static const String iconNavClose = 'assets/icons/nav_close.png';
  static const String iconSend = 'assets/icons/send.png';
  static const String iconSendDisable = 'assets/icons/send_disable.png';

  static const String iconBack = 'assets/icons/back.png';

  static const String memberCameraNormal =
      'assets/icons/video_camera_on.png';
  static const String memberCameraOff = 'assets/icons/video_camera_off.png';
  static const String memberMicNormal = 'assets/icons/mic_on.png';
  static const String memberMicOff = 'assets/icons/mic_off.png';
  static const String memberMicSpeaking =
      'assets/icons/speaker_on.png';

  static const String messageLoading = 'assets/icons/message_loading.png';
  static const String messageFail = 'assets/icons/message_fail.png';
}
