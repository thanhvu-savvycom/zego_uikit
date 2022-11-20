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
