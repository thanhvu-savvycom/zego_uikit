part of 'zego_uikit_core.dart';

enum ZegoStreamType {
  main,
  media,
  screenSharing,
}

// user
class ZegoUIKitCoreUser {
  String id = '';
  String name = '';
  String streamID = '';

  ValueNotifier<bool> camera = ValueNotifier<bool>(false);
  ValueNotifier<bool> microphone = ValueNotifier<bool>(false);
  StreamController<double> soundLevel = StreamController<double>.broadcast();
  var inRoomAttributes = ValueNotifier<Map<String, String>>({});

  int viewID = -1;
  ValueNotifier<Widget?> view = ValueNotifier<Widget?>(null);
  ValueNotifier<Size> viewSize = ValueNotifier<Size>(const Size(360, 640));
  int textureWidth = -1;
  int textureHeight = -1;

  void destroyTextureRenderer() {
    if (viewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(viewID);
    }

    viewID = -1;
    view.value = null;
    viewSize.value = const Size(360, 640);
    textureWidth = -1;
    textureHeight = -1;
  }

  ValueNotifier<ZegoStreamQualityLevel> network =
      ValueNotifier<ZegoStreamQualityLevel>(ZegoStreamQualityLevel.Excellent);

  // only for local
  ValueNotifier<bool> isFrontFacing = ValueNotifier<bool>(true);
  ValueNotifier<ZegoAudioRoute> audioRoute =
      ValueNotifier<ZegoAudioRoute>(ZegoAudioRoute.Receiver);
  ZegoAudioRoute lastAudioRoute = ZegoAudioRoute.Receiver;

  ZegoUIKitCoreUser(this.id, this.name);

  ZegoUIKitCoreUser.localDefault() {
    camera.value = true;
    microphone.value = true;
  }

  ZegoUIKitCoreUser.empty();

  ZegoUIKitCoreUser.fromZego(ZegoUser user) : this(user.userID, user.userName);

  ZegoUIKitUser toZegoUikitUser() => ZegoUIKitUser(id: id, name: name);

  ZegoUser toZegoUser() => ZegoUser(id, name);

  @override
  String toString() {
    return "id:$id, name:$name";
  }
}

String generateStreamID(String userID, String roomID, ZegoStreamType type) {
  return '${roomID}_${userID}_${type.name}';
}

// room

class ZegoUIKitCoreRoom {
  String id = '';

  var state = ValueNotifier<ZegoUIKitRoomState>(
      ZegoUIKitRoomState(ZegoRoomStateChangedReason.Logout, 0, {}));

  Map<String, RoomProperty> properties = {};
  bool propertiesAPIRequesting = false;
  Map<String, String> pendingProperties = {};

  var propertyUpdateStream = StreamController<RoomProperty>.broadcast();
  var propertiesUpdatedStream =
      StreamController<Map<String, RoomProperty>>.broadcast();

  ZegoUIKitCoreRoom(this.id) {
    debugPrint("create $id");
  }

  void clear() {
    id = '';

    properties.clear();
    propertiesAPIRequesting = false;
    pendingProperties.clear();
  }

  ZegoUIKitRoom toUIKitRoom() {
    return ZegoUIKitRoom(id: id);
  }
}

// video config
class ZegoUIKitVideoConfig {
  ZegoVideoConfigPreset resolution;
  DeviceOrientation orientation;
  bool useVideoViewAspectFill;

  ZegoUIKitVideoConfig({
    this.resolution = ZegoVideoConfigPreset.Preset360P,
    this.orientation = DeviceOrientation.portraitUp,
    this.useVideoViewAspectFill = false,
  });

  bool needUpdateOrientation(ZegoUIKitVideoConfig newConfig) {
    return orientation != newConfig.orientation;
  }

  bool needUpdateVideoConfig(ZegoUIKitVideoConfig newConfig) {
    return (resolution != newConfig.resolution) ||
        (orientation != newConfig.orientation);
  }

  ZegoVideoConfig toZegoVideoConfig() {
    ZegoVideoConfig config = ZegoVideoConfig.preset(resolution);
    if (orientation == DeviceOrientation.landscapeLeft ||
        orientation == DeviceOrientation.landscapeRight) {
      int tmp = config.captureHeight;
      config.captureHeight = config.captureWidth;
      config.captureWidth = tmp;
      tmp = config.encodeHeight;
      config.encodeHeight = config.encodeWidth;
      config.encodeWidth = tmp;
    }
    return config;
  }

  ZegoUIKitVideoConfig copyWith({
    ZegoVideoConfigPreset? resolution,
    DeviceOrientation? orientation,
    bool? useVideoViewAspectFill,
  }) =>
      ZegoUIKitVideoConfig(
        resolution: resolution ?? this.resolution,
        orientation: orientation ?? this.orientation,
        useVideoViewAspectFill:
            useVideoViewAspectFill ?? this.useVideoViewAspectFill,
      );
}

class ZegoUIKitAdvancedConfigKey {
  static const String videoViewMode = 'videoViewMode';
}
