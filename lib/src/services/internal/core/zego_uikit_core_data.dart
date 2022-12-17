part of 'zego_uikit_core.dart';

class ZegoUIKitCoreData {
  ZegoUIKitCoreUser localUser = ZegoUIKitCoreUser.localDefault();

  final List<ZegoUIKitCoreUser> remoteUsersList = [];

  final Map<String, String> streamDic = {}; // stream_id:user_id

  ZegoUIKitCoreRoom room = ZegoUIKitCoreRoom('');

  bool isAllPlayStreamAudioVideoMuted = false;

  var userJoinStreamCtrl =
      StreamController<List<ZegoUIKitCoreUser>>.broadcast();
  var userLeaveStreamCtrl =
      StreamController<List<ZegoUIKitCoreUser>>.broadcast();
  var userListStreamCtrl =
      StreamController<List<ZegoUIKitCoreUser>>.broadcast();

  var audioVideoListStreamCtrl =
      StreamController<List<ZegoUIKitCoreUser>>.broadcast();

  var meRemovedFromRoomStreamCtrl = StreamController<String>.broadcast();
  var customCommandReceivedStreamCtrl =
      StreamController<ZegoInRoomCommandReceivedData>.broadcast();
  var networkModeStreamCtrl = StreamController<ZegoNetworkMode>.broadcast();

  var turnOnYourCameraRequestStreamCtrl = StreamController<String>.broadcast();
  var turnOnYourMicrophoneRequestStreamCtrl =
      StreamController<String>.broadcast();

  ZegoUIKitVideoConfig videoConfig = ZegoUIKitVideoConfig();

  var beautyParam = ZegoEffectsBeautyParam.defaultParam();

  void clearStream() {
    debugPrint("[core] clear stream");

    for (var user in remoteUsersList) {
      if (user.streamID.isNotEmpty) {
        stopPlayingStream(user.streamID);
      }
      user.destroyTextureRenderer();
    }

    if (localUser.streamID.isNotEmpty) {
      stopPublishingStream();
    }
    localUser.destroyTextureRenderer();
  }

  void clear() {
    debugPrint("[core] clear");

    clearStream();

    isAllPlayStreamAudioVideoMuted = false;

    remoteUsersList.clear();
    streamDic.clear();
    room.clear();
  }

  ZegoUIKitCoreUser login(String id, String name) {
    debugPrint("[core] login, id:\"$id\", name:$name");

    localUser.id = id;
    localUser.name = name;

    userJoinStreamCtrl.add([localUser]);
    var allUserList = [localUser, ...remoteUsersList];
    userListStreamCtrl.add(allUserList);

    return localUser;
  }

  void logout() {
    debugPrint("[core] logout");

    localUser.id = '';
    localUser.name = '';

    userLeaveStreamCtrl.add([localUser]);
    userListStreamCtrl.add(remoteUsersList);
  }

  void setRoom(
    String roomID, {
    bool markAsLargeRoom = false,
  }) {
    debugPrint(
        "[core] set room:\"$roomID\", markAsLargeRoom:$markAsLargeRoom}");

    room.id = roomID;
    room.markAsLargeRoom = markAsLargeRoom;
  }

  Future<void> startPreview() async {
    debugPrint("[core] start preview");

    createLocalUserVideoView(onViewCreated: () async {
      debugPrint("[core] start preview, on view created");

      assert(localUser.viewID != -1);

      ZegoCanvas previewCanvas = ZegoCanvas(
        localUser.viewID,
        viewMode: videoConfig.useVideoViewAspectFill
            ? ZegoViewMode.AspectFill
            : ZegoViewMode.AspectFit,
      );

      if (kIsWeb) {
        ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
      } else {
        ZegoExpressEngine.instance
          ..enableCamera(localUser.camera.value)
          ..startPreview(canvas: previewCanvas);
      }
    });
  }

  Future<void> stopPreview() async {
    debugPrint("[core] stop preview");

    localUser.destroyTextureRenderer();

    ZegoExpressEngine.instance.stopPreview();
  }

  Future<void> startPublishingStream() async {
    if (localUser.streamID.isNotEmpty) {
      debugPrint("[core] startPublishingStream local user stream id is empty");
      return;
    }

    localUser.streamID =
        generateStreamID(localUser.id, room.id, ZegoStreamType.main);
    streamDic[localUser.streamID] = localUser.id;

    debugPrint("[core] startPublishingStream ${localUser.streamID}");

    createLocalUserVideoView(onViewCreated: () async {
      assert(localUser.viewID != -1);
      ZegoCanvas previewCanvas = ZegoCanvas(
        localUser.viewID,
        viewMode: videoConfig.useVideoViewAspectFill
            ? ZegoViewMode.AspectFill
            : ZegoViewMode.AspectFit,
      );
      if (kIsWeb) {
        ZegoExpressEngine.instance
          ..mutePublishStreamVideo(!localUser.camera.value)
          ..mutePublishStreamAudio(!!localUser.microphone.value)
          ..startPreview(canvas: previewCanvas)
          ..startPublishingStream(localUser.streamID).then((value) {
            audioVideoListStreamCtrl.add(getAudioVideoList());
          });
      } else {
        ZegoExpressEngine.instance
          ..enableCamera(localUser.camera.value)
          ..muteMicrophone(!localUser.microphone.value)
          ..startPreview(canvas: previewCanvas)
          ..startPublishingStream(localUser.streamID).then((value) {
            audioVideoListStreamCtrl.add(getAudioVideoList());
          });
      }
    });
  }

  Future<void> stopPublishingStream() async {
    debugPrint("[core] stopPublishingStream ${localUser.streamID}");

    assert(localUser.streamID.isNotEmpty);

    streamDic.remove(localUser.streamID);
    localUser.streamID = "";
    localUser.destroyTextureRenderer();

    ZegoExpressEngine.instance
      ..stopPreview()
      ..stopPublishingStream().then((value) {
        audioVideoListStreamCtrl.add(getAudioVideoList());
      });
  }

  Future<void> startPublishOrNot() async {
    if (room.id.isEmpty) {
      debugPrint("[core] startPublishOrNot room id is empty");
      return;
    }

    if (localUser.camera.value || localUser.microphone.value) {
      startPublishingStream();
    } else {
      if (localUser.streamID.isNotEmpty) {
        stopPublishingStream();
      }
    }
  }

  void createLocalUserVideoView({required VoidCallback onViewCreated}) {
    if (-1 == localUser.viewID) {
      ZegoExpressEngine.instance.createCanvasView((viewID) {
        localUser.viewID = viewID;
        onViewCreated();

        audioVideoListStreamCtrl.add(getAudioVideoList());
      }).then((widget) {
        localUser.view.value = widget;
      });
    } else {
      //  user view had created
      onViewCreated();
    }
  }

  ZegoUIKitCoreUser removeUser(String uid) {
    var targetIndex = remoteUsersList.indexWhere((user) => uid == user.id);
    if (-1 == targetIndex) {
      return ZegoUIKitCoreUser.empty();
    }

    var targetUser = remoteUsersList.removeAt(targetIndex);
    if (targetUser.streamID.isNotEmpty) {
      stopPlayingStream(targetUser.streamID);
    }
    return targetUser;
  }

  void muteAllPlayStreamAudioVideo(bool isMuted) async {
    debugPrint("[core] mute all play stream audio video: $isMuted");

    isAllPlayStreamAudioVideoMuted = isMuted;

    ZegoExpressEngine.instance
        .muteAllPlayStreamVideo(isAllPlayStreamAudioVideoMuted);
    ZegoExpressEngine.instance
        .muteAllPlayStreamAudio(isAllPlayStreamAudioVideoMuted);

    streamDic.forEach((streamID, userID) {
      if (isMuted) {
        // stop playing stream
        ZegoExpressEngine.instance.stopPlayingStream(streamID);
      } else {
        if (localUser.id != userID) {
          startPlayingStream(streamID, userID);
        }
      }
    });
  }

  /// will change data variables
  Future<void> startPlayingStream(String streamID, String streamUserID) async {
    debugPrint("[core] start play stream id: $streamID, user id:$streamUserID");

    var targetUserIndex =
        remoteUsersList.indexWhere((user) => streamUserID == user.id);
    assert(-1 != targetUserIndex);
    remoteUsersList[targetUserIndex].streamID = streamID;

    ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteUsersList[targetUserIndex].viewID = viewID;
      ZegoCanvas canvas = ZegoCanvas(
        viewID,
        viewMode: videoConfig.useVideoViewAspectFill
            ? ZegoViewMode.AspectFill
            : ZegoViewMode.AspectFit,
      );
      ZegoExpressEngine.instance
          .startPlayingStream(streamID, canvas: canvas)
          .then((value) {
        audioVideoListStreamCtrl.add(getAudioVideoList());
      });
    }).then((widget) {
      remoteUsersList[targetUserIndex].view.value = widget;
    });
  }

  /// will change data variables
  void stopPlayingStream(String streamID) {
    debugPrint("[core] stop play stream id: $streamID");
    assert(streamID.isNotEmpty);

    // stop playing stream
    ZegoExpressEngine.instance.stopPlayingStream(streamID);

    var targetUserID =
        streamDic.containsKey(streamID) ? streamDic[streamID] : "";
    debugPrint(
        "[core] stopped play stream id $streamID, user id  is: $targetUserID");
    var targetUserIndex =
        remoteUsersList.indexWhere((user) => targetUserID == user.id);
    if (-1 != targetUserIndex) {
      ZegoUIKitCoreUser targetUser = remoteUsersList[targetUserIndex];
      if (targetUser.streamID != streamID) {
        debugPrint("[core] stream id is not equal, stream id:$streamID, "
            "target user ${targetUser.id} ${targetUser.name} stream id:${targetUser.streamID}");
        assert(targetUser.streamID == streamID);
      }
      targetUser.streamID = "";
      targetUser.camera.value = false;
      targetUser.microphone.value = false;
      targetUser.soundLevel.add(0);
      targetUser.destroyTextureRenderer();
    }

    // clear streamID
    streamDic.remove(streamID);
  }

  Future<void> onRoomStreamUpdate(String roomID, ZegoUpdateType updateType,
      List<ZegoStream> streamList, Map<String, dynamic> extendedData) async {
    debugPrint(
        "[core] onRoomStreamUpdate, roomID:$roomID, update type:$updateType"
        ", stream list:${streamList.map((e) => "stream id:${e.streamID}, extra info${e.extraInfo}, user id:${e.user.userID}")},"
        " extended data:$extendedData");

    if (updateType == ZegoUpdateType.Add) {
      for (final stream in streamList) {
        streamDic[stream.streamID] = stream.user.userID;
        if (-1 ==
            remoteUsersList
                .indexWhere((user) => stream.user.userID == user.id)) {
          /// user is not exist before stream added
          debugPrint(
              "[core] stream's user ${stream.user.userID}  ${stream.user.userName} is not exist, create");

          var targetUser = ZegoUIKitCoreUser.fromZego(stream.user);
          targetUser.streamID = stream.streamID;
          remoteUsersList.add(targetUser);
        }

        if (isAllPlayStreamAudioVideoMuted) {
          debugPrint(
              "audio video is not play enabled, user id:${stream.user.userID}, stream id:${stream.streamID}");
        } else {
          await startPlayingStream(stream.streamID, stream.user.userID);
        }
      }

      onRoomStreamExtraInfoUpdate(roomID, streamList);
    } else {
      for (final stream in streamList) {
        stopPlayingStream(stream.streamID);
      }
    }

    audioVideoListStreamCtrl.add(getAudioVideoList());
  }

  void onRoomStreamExtraInfoUpdate(String roomID, List<ZegoStream> streamList) {
    /*
    * {
    * "isCameraOn": true,
    * "isMicrophoneOn": true,
    * "hasAudio": true,
    * "hasVideo": true,
    * }
    * */

    debugPrint(
        "[core] onRoomStreamExtraInfoUpdate, roomID:$roomID, stream list:${streamList.map((e) => "stream id:${e.streamID}, extra info${e.extraInfo}, user id:${e.user.userID}")}");
    for (var stream in streamList) {
      if (stream.extraInfo.isEmpty) {
        debugPrint("[core] onRoomStreamExtraInfoUpdate extra info is empty");
        continue;
      }

      var extraInfos = jsonDecode(stream.extraInfo) as Map<String, dynamic>;
      if (extraInfos.containsKey(streamExtraInfoCameraKey)) {
        onRemoteCameraStateUpdate(
            stream.streamID,
            extraInfos[streamExtraInfoCameraKey]!
                ? ZegoRemoteDeviceState.Open
                : ZegoRemoteDeviceState.Mute);
      }
      if (extraInfos.containsKey(streamExtraInfoMicrophoneKey)) {
        onRemoteMicStateUpdate(
            stream.streamID,
            extraInfos[streamExtraInfoMicrophoneKey]!
                ? ZegoRemoteDeviceState.Open
                : ZegoRemoteDeviceState.Mute);
      }
    }
  }

  List<ZegoUIKitCoreUser> getAudioVideoList() {
    return streamDic.entries
        .map((entry) {
          var targetUserID = entry.value;
          if (targetUserID == localUser.id) {
            return localUser;
          }
          return remoteUsersList.firstWhere((user) => targetUserID == user.id,
              orElse: () => ZegoUIKitCoreUser.empty());
        })
        .where((user) => user.id.isNotEmpty)
        .toList();
  }

  void onRoomUserUpdate(
      String roomID, ZegoUpdateType updateType, List<ZegoUser> userList) {
    debugPrint(
        "[core] onRoomUserUpdate, room id:\"$roomID\", update type:$updateType"
        "user list:${userList.map((user) => "\"${user.userID}\":${user.userName}, ")}");

    if (updateType == ZegoUpdateType.Add) {
      for (final _user in userList) {
        var targetUserIndex =
            remoteUsersList.indexWhere((user) => _user.userID == user.id);
        if (-1 != targetUserIndex) {
          continue;
        }

        remoteUsersList.add(ZegoUIKitCoreUser.fromZego(_user));
      }

      if (remoteUsersList.length >= 499) {
        /// turn to be a large room after more than 500 people, even if less than 500 people behind
        debugPrint("[core] users is more than 500, turn to be a large room");
        room.isLargeRoom = true;
      }

      userJoinStreamCtrl.add(
          userList.map((user) => ZegoUIKitCoreUser.fromZego(user)).toList());
    } else {
      for (final user in userList) {
        removeUser(user.userID);
      }

      userLeaveStreamCtrl.add(
          userList.map((user) => ZegoUIKitCoreUser.fromZego(user)).toList());
    }

    var allUserList = [localUser, ...remoteUsersList];
    userListStreamCtrl.add(allUserList);
  }

  void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
      int errorCode, Map<String, dynamic> extendedData) {
    debugPrint(
        "[core] onPublisherStateUpdate, stream id:$streamID, state:$state, errorCode:$errorCode, extendedData:$extendedData");
  }

  void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
      int errorCode, Map<String, dynamic> extendedData) {
    debugPrint(
        "[core] onPlayerStateUpdate, stream id:$streamID, state:$state, errorCode:$errorCode, extendedData:$extendedData");
  }

  void onRemoteCameraStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    var targetUserIndex =
        remoteUsersList.indexWhere((user) => streamDic[streamID]! == user.id);
    if (-1 == targetUserIndex) {
      debugPrint(
          "[core] onRemoteCameraStateUpdate, stream user $streamID is not exist");
      return;
    }

    ZegoUIKitCoreUser targetUser = remoteUsersList[targetUserIndex];
    debugPrint(
        "[core] onRemoteCameraStateUpdate, stream id:$streamID, user:${targetUser.toString()}, state:$state");
    switch (state) {
      case ZegoRemoteDeviceState.Open:
        targetUser.camera.value = true;
        break;
      case ZegoRemoteDeviceState.NoAuthorization:
        targetUser.camera.value = true;
        break;
      default:
        targetUser.camera.value = false;
    }
  }

  void onRemoteMicStateUpdate(String streamID, ZegoRemoteDeviceState state) {
    var targetUserIndex =
        remoteUsersList.indexWhere((user) => streamDic[streamID]! == user.id);
    if (-1 == targetUserIndex) {
      debugPrint(
          "[core] onRemoteMicStateUpdate, stream user $streamID is not exist");
      return;
    }

    ZegoUIKitCoreUser targetUser = remoteUsersList[targetUserIndex];
    debugPrint(
        "[core] onRemoteMicStateUpdate, stream id:$streamID, user:${targetUser.toString()}, state:$state");
    switch (state) {
      case ZegoRemoteDeviceState.Open:
        targetUser.microphone.value = true;
        break;
      case ZegoRemoteDeviceState.NoAuthorization:
        targetUser.microphone.value = true;
        break;
      default:
        targetUser.microphone.value = false;
        targetUser.soundLevel.add(0);
    }
  }

  void onRemoteSoundLevelUpdate(Map<String, double> soundLevels) {
    soundLevels.forEach((streamID, soundLevel) {
      if (!streamDic.containsKey(streamID)) {
        debugPrint("[core] stream dic does not contain $streamID");
        return;
      }

      var targetUserID = streamDic[streamID]!;
      var targetUserIndex =
          remoteUsersList.indexWhere((user) => targetUserID == user.id);
      if (-1 == targetUserIndex) {
        debugPrint("[core] remote user does not contain $targetUserID");
        return;
      }

      remoteUsersList[targetUserIndex].soundLevel.add(soundLevel);
    });
  }

  void onCapturedSoundLevelUpdate(double level) {
    localUser.soundLevel.add(level);
  }

  void onAudioRouteChange(ZegoAudioRoute audioRoute) {
    localUser.audioRoute.value = audioRoute;
  }

  void onPlayerVideoSizeChanged(String streamID, int width, int height) {
    var targetUserIndex =
        remoteUsersList.indexWhere((user) => streamDic[streamID]! == user.id);
    if (-1 == targetUserIndex) {
      debugPrint(
          "onPlayerVideoSizeChanged, stream user $streamID is not exist");
      return;
    }

    ZegoUIKitCoreUser targetUser = remoteUsersList[targetUserIndex];
    debugPrint(
        "[core] onPlayerVideoSizeChanged streamID: $streamID width: $width height: $height");
    Size size = Size(width.toDouble(), height.toDouble());
    if (targetUser.viewSize.value != size) {
      targetUser.viewSize.value = size;
    }
  }

  void onRoomStateChanged(String roomID, ZegoRoomStateChangedReason reason,
      int errorCode, Map<String, dynamic> extendedData) {
    debugPrint(
        "[core] onRoomStateChanged roomID: $roomID, reason: $reason, errorCode: $errorCode, extendedData: $extendedData");

    room.state.value = ZegoUIKitRoomState(reason, errorCode, extendedData);

    if (reason == ZegoRoomStateChangedReason.KickOut) {
      debugPrint("[core] local user had been kick out by room state changed");

      meRemovedFromRoomStreamCtrl.add("");
    }
  }

  void onRoomExtraInfoUpdate(
      String roomID, List<ZegoRoomExtraInfo> roomExtraInfoList) {
    var roomExtraInfoString = roomExtraInfoList.map((info) =>
        "key:${info.key}, value:${info.value}"
        " update user:${info.updateUser.userID},${info.updateUser.userName}, update time:${info.updateTime}");
    debugPrint(
        "[core] onRoomExtraInfoUpdate roomID: $roomID,roomExtraInfoList: $roomExtraInfoString");

    for (var extraInfo in roomExtraInfoList) {
      if (extraInfo.key == "extra_info") {
        var properties = jsonDecode(extraInfo.value) as Map<String, dynamic>;

        debugPrint("[core] update room properties: $properties");

        Map<String, RoomProperty> updateProperties = {};

        properties.forEach((key, _value) {
          String value = _value as String;

          if (room.properties.containsKey(key) &&
              room.properties[key]!.value == value) {
            debugPrint(
                "[core] room property not need update, key:$key, value:$value");
            return;
          }

          debugPrint("[core] room property update, key:$key, value:$value");
          if (room.properties.containsKey(key)) {
            var property = room.properties[key]!;
            if (extraInfo.updateTime > property.updateTime) {
              room.properties[key]!.oldValue = room.properties[key]!.value;
              room.properties[key]!.value = value;
              room.properties[key]!.updateTime = extraInfo.updateTime;
              room.properties[key]!.updateUserID = extraInfo.updateUser.userID;
            }
          } else {
            room.properties[key] = RoomProperty(
              key,
              value,
              extraInfo.updateTime,
              extraInfo.updateUser.userID,
            );
          }
          updateProperties[key] = room.properties[key]!;
          room.propertyUpdateStream.add(room.properties[key]!);
        });

        if (updateProperties.isNotEmpty) {
          room.propertiesUpdatedStream.add(updateProperties);
        }
      }
    }
  }

  void onIMRecvCustomCommand(String roomID, ZegoUser fromUser, String command) {
    debugPrint(
        "[core] onIMRecvCustomCommand roomID: $roomID, reason: ${fromUser.userID} ${fromUser.userName}, command:$command");

    customCommandReceivedStreamCtrl.add(ZegoInRoomCommandReceivedData(
      fromUser: ZegoUIKitUser.fromZego(fromUser),
      command: command,
    ));
  }

  void onNetworkModeChanged(ZegoNetworkMode mode) {
    networkModeStreamCtrl.add(mode);
  }
}
