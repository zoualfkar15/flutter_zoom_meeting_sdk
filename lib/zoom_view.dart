import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_zoom/zoom_options.dart';
import 'package:flutter_zoom/zoom_platform_view.dart';

class ZoomView extends ZoomPlatform {
  final MethodChannel channel = const MethodChannel('com.zoualfkar/flutter_zoom');

  /// The event channel used to interact with the native platform.
  final EventChannel eventChannel = const EventChannel('com.zoualfkar/flutter_zoom_event_stream');

  /// The event channel used to interact with the native platform init function
  @override
  Future<List> initZoom(ZoomOptions options) async {
    var optionMap = <String, String?>{};

    if (options.jwtToken != null) {
      optionMap.putIfAbsent("jwtToken", () => options.jwtToken!);
    }

    optionMap.putIfAbsent("domain", () => options.domain);
    return await channel
        .invokeMethod<List>('init', optionMap)
        .then<List>((List? value) => value ?? List.empty());
  }

  @override
  Future<bool> unInitialize() async {
    return await channel
        .invokeMethod<bool>('unInitialize')
        .then<bool>((bool? value) => value ?? false);
  }



  /// The event channel used to interact with the native platform startMeetingNormal function
  @override
  Future<List> startMeeting(ZoomMeetingOptions options) async {
    var optionMap = <String, String?>{};
    optionMap.putIfAbsent("zoomAccessToken", () => options.zoomAccessToken);
    optionMap.putIfAbsent("displayName", () => options.displayName);
    optionMap.putIfAbsent("meetingId", () => options.meetingId);
    optionMap.putIfAbsent("disableDialIn", () => options.disableDialIn);
    optionMap.putIfAbsent("disableMinimizeMeeting", () => options.disableMinimizeMeeting);
    optionMap.putIfAbsent("disableDrive", () => options.disableDrive);
    optionMap.putIfAbsent("disableInvite", () => options.disableInvite);
    optionMap.putIfAbsent("disableShare", () => options.disableShare);
    optionMap.putIfAbsent("disableTitlebar", () => options.disableTitlebar);
    optionMap.putIfAbsent("noDisconnectAudio", () => options.noDisconnectAudio);
    optionMap.putIfAbsent("noAudio", () => options.noAudio);
    optionMap.putIfAbsent("viewOptions", () => options.viewOptions);

    return await channel
        .invokeMethod<List>('startMeeting', optionMap)
        .then<List>((List? value) => value ?? List.empty());
  }

  /// The event channel used to interact with the native platform joinMeeting function
  @override
  Future<bool> joinMeeting(ZoomMeetingOptions options) async {
    var optionMap = <String, String?>{};
    optionMap.putIfAbsent("zoomAccessToken", () => options.zoomAccessToken);
    optionMap.putIfAbsent("displayName", () => options.displayName);
    optionMap.putIfAbsent("meetingId", () => options.meetingId);
    optionMap.putIfAbsent("meetingPassword", () => options.meetingPassword);
    optionMap.putIfAbsent("disableDialIn", () => options.disableDialIn);
    optionMap.putIfAbsent("disableMinimizeMeeting", () => options.disableMinimizeMeeting);
    optionMap.putIfAbsent("disableDrive", () => options.disableDrive);
    optionMap.putIfAbsent("disableInvite", () => options.disableInvite);
    optionMap.putIfAbsent("disableShare", () => options.disableShare);
    optionMap.putIfAbsent("disableTitlebar", () => options.disableTitlebar);
    optionMap.putIfAbsent("noDisconnectAudio", () => options.noDisconnectAudio);
    optionMap.putIfAbsent("viewOptions", () => options.viewOptions);
    optionMap.putIfAbsent("noAudio", () => options.noAudio);

    return await channel
        .invokeMethod<bool>('join', optionMap)
        .then<bool>((bool? value) => value ?? false);
  }
  
  /// The event channel used to interact with the native platform returnToMeeting function
  @override
  Future<bool> returnToMeeting() async {
    return await channel
        .invokeMethod<bool>('return')
        .then<bool>((bool? value) => value ?? false);
  }



  /// The event channel used to interact with the native platform meetingStatus function
  @override
  Future<List> meetingStatus(String meetingId) async {
    var optionMap = <String, String>{};
    optionMap.putIfAbsent("meetingId", () => meetingId);

    return await channel
        .invokeMethod<List>('meeting_status', optionMap)
        .then<List>((List? value) => value ?? List.empty());
  }

  /// The event channel used to interact with the native platform onMeetingStatus(iOS & Android) function
  @override
  Stream<dynamic> onMeetingStatus() {
    return eventChannel.receiveBroadcastStream();
  }

  /// The event channel used to interact with the native platform meetinDetails(iOS & Android) function
  @override
  Future<List> meetinDetails() async {
    return await channel
        .invokeMethod<List>('meeting_details')
        .then<List>((List? value) => value ?? List.empty());
  }
}
