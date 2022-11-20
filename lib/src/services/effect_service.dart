part of 'uikit_service.dart';

mixin ZegoEffectService {
  Future<void> enableBeauty(bool isOn) async {
    ZegoUIKitCore.shared.enableBeauty(isOn);
  }

  Future<void> startEffectsEnv() async {
    ZegoUIKitCore.shared.startEffectsEnv();
  }

  Future<void> stopEffectsEnv() async {
    ZegoUIKitCore.shared.stopEffectsEnv();
  }

  /// Set the intensity of the specific face beautify feature
  /// Description: After the face beautify feature is enabled, you can specify the parameters to set the intensity of the specific feature as needed.
  ///
  /// Call this method at: After enabling the face beautify feature.
  ///
  /// @param value refers to the range value of the specific face beautification feature or face shape retouch feature.
  /// @param type  refers to the specific face beautification feature or face shape retouch feature.
  void setBeautifyValue(int value, BeautyEffectType type) {
    if (BeautyEffectType.none == type) {
      return;
    }

    switch (type) {
      case BeautyEffectType.whiten:
        ZegoUIKitCore.shared.coreData.beautyParam.whitenIntensity = value;
        break;
      case BeautyEffectType.rosy:
        ZegoUIKitCore.shared.coreData.beautyParam.rosyIntensity = value;
        break;
      case BeautyEffectType.smooth:
        ZegoUIKitCore.shared.coreData.beautyParam.smoothIntensity = value;
        break;
      case BeautyEffectType.sharpen:
        ZegoUIKitCore.shared.coreData.beautyParam.sharpenIntensity = value;
        break;
      case BeautyEffectType.none:
        break;
    }

    debugPrint("set beauty $type value: $value");

    ZegoExpressEngine.instance
        .setEffectsBeautyParam(ZegoUIKitCore.shared.coreData.beautyParam);
  }

  ZegoEffectsBeautyParam getBeautyValue() {
    return ZegoUIKitCore.shared.coreData.beautyParam;
  }

  /// Set voice changing
  /// Description: This method can be used to change the voice with voice effects.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param voicePreset refers to the voice type you want to changed to.
  void setVoiceChangerType(ZegoVoiceChangerPreset voicePreset) {
    debugPrint("set voice changing type: $voicePreset");
    ZegoExpressEngine.instance.setVoiceChangerPreset(voicePreset);
  }

  /// Set reverb
  /// Description: This method can be used to use the reverb effect in the room.
  ///
  /// Call this method at: After joining a room
  ///
  /// @param reverbPreset refers to the reverb type you want to select.
  void setReverbType(ZegoReverbPreset reverbPreset) {
    debugPrint("set reverb type: $reverbPreset");
    ZegoExpressEngine.instance.setReverbPreset(reverbPreset);
  }

  Future<void> resetSoundEffect() async {
    await ZegoExpressEngine.instance.setReverbPreset(ZegoReverbPreset.None);
    await ZegoExpressEngine.instance
        .setVoiceChangerPreset(ZegoVoiceChangerPreset.None);
  }

  Future<void> resetBeautyEffect() async {
    ZegoUIKitCore.shared.coreData.beautyParam =
        ZegoEffectsBeautyParam.defaultParam();
    await ZegoExpressEngine.instance
        .setEffectsBeautyParam(ZegoEffectsBeautyParam.defaultParam());
  }
}
