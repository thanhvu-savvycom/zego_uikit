export 'room_message/defines.dart';
export 'user_attributes/defines.dart';
export 'room_properties/defines.dart';

/// signaling plugin function result
class ZegoSignalingPluginResult {
  /// An error code.
  final String code;

  /// A human-readable error message
  final String message;

  /// result
  final dynamic result;

  ZegoSignalingPluginResult(this.code, this.message, {this.result});

  ZegoSignalingPluginResult.empty(
      {this.code = "", this.message = "", this.result = ""});
}
