// Project imports:
import 'package:zego_uikit/zego_uikit.dart';

mixin ZegoUIKitInvitationService {
  /// send invitation to one or more specified users
  /// [invitees] list of invitees.
  /// [timeout]timeout of the call invitation, the unit is seconds
  /// [type] call type
  /// [data] extended field, through which the inviter can carry information to the invitee.
  Future<ZegoSignalingPluginResult> sendInvitation(
    String inviterName,
    List<String> invitees,
    int timeout,
    int type,
    String data,
  ) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('sendInvitation', {
      'inviterName': inviterName,
      'invitees': invitees,
      'timeout': timeout,
      'type': type,
      'data': data,
    });

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
      result: result['errorInvitees'] as List<String>,
    );
  }

  /// cancel invitation to one or more specified users
  /// [inviteeID] invitee's id
  /// [data] extended field
  Future<ZegoSignalingPluginResult> cancelInvitation(
      List<String> invitees, String data) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('cancelInvitation', {
      'invitees': invitees,
      'data': data,
    });

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
      result: result['errorInvitees'] as List<String>,
    );
  }

  /// refuse invitation
  Future<ZegoSignalingPluginResult> refuseInvitation(
      String inviterID, String data) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('refuseInvitation', {
      'inviterID': inviterID,
      'data': data,
    });

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
    );
  }

  /// invitee accept the call invitation
  /// [inviterID] inviter id, who send invitation
  /// [data] extended field
  Future<ZegoSignalingPluginResult> acceptInvitation(
      String inviterID, String data) async {
    Map result = await ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .invoke('acceptInvitation', {
      'inviterID': inviterID,
      'data': data,
    });

    return ZegoSignalingPluginResult(
      result["errorCode"] as String,
      result["errorMessage"] as String,
    );
  }

  /// stream callback
  Stream<Map> getConnectionStateStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('connectionState');
  }

  /// stream callback
  Stream<Map> getRoomStateStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('roomState');
  }

  /// stream callback, notify invitee when call invitation received
  Stream<Map> getInvitationReceivedStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('invitationReceived');
  }

  /// stream callback, notify invitee if invitation timeout
  Stream<Map> getInvitationTimeoutStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('invitationTimeout');
  }

  /// stream callback, When the call invitation times out, the invitee does not respond, and the inviter will receive a callback.
  Stream<Map> getInvitationResponseTimeoutStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('invitationResponseTimeout');
  }

  /// stream callback, notify when call invitation accepted by invitee
  Stream<Map> getInvitationAcceptedStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('invitationAccepted');
  }

  /// stream callback, notify when call invitation rejected by invitee
  Stream<Map> getInvitationRefusedStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('invitationRefused');
  }

  /// stream callback, notify when call invitation cancelled by inviter
  Stream<Map> getInvitationCanceledStream() {
    return ZegoUIKit()
        .getPlugin(ZegoUIKitPluginType.signaling)!
        .getEventStream('invitationCanceled');
  }
}
