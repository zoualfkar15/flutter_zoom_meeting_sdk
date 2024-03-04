

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_zoom/zoom_options.dart';
import 'package:flutter_zoom/zoom_view.dart';
import 'package:flutter_zoom_example/zoom/jwt.dart';


bool _isMeetingEnded(String status) {
  var result = false;

  if (Platform.isAndroid) {
    result = status == "MEETING_STATUS_DISCONNECTING" ||
        status == "MEETING_STATUS_FAILED";
  } else {
    result = status == "MEETING_STATUS_IDLE";
  }

  return result;
}


joinMeeting({
  required String meetingId,
  required String zoomAccessToken,
  required String displayName,
  required String password,
}) {



  ZoomOptions zoomOptions = ZoomOptions(
      domain: "zoom.us",
      jwtToken: generateZoomJWT()
  );
  var meetingOptions = ZoomMeetingOptions(
      zoomAccessToken:zoomAccessToken,
      meetingId: meetingId,
      meetingPassword: password,
      displayName: displayName,

      /// pass meeting password for join meeting only
      disableDialIn: "true",
      disableDrive: "true",
      disableInvite: "true",
      disableShare: "true",
      disableTitlebar: "false",
      viewOptions: "true",
      noAudio: "false",
      noDisconnectAudio: "false");

  var zoom = ZoomView();
  zoom.initZoom(zoomOptions).then((results) {

    print('---------- pip pip success initialize zoom sdk');
    if (results[0] == 0) {
      zoom.onMeetingStatus().listen((status) {
        if (kDebugMode) {
          print(
              "[Meeting Status Stream] : " + status[0] + " - " + status[1]);
        }
        if (_isMeetingEnded(status[0])) {
          unInitialize();
          if (kDebugMode) {
            print("[Meeting Status] :- Ended");
          }
        }
      });
      if (kDebugMode) {
        print("listen on event channel");
      }
      zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {
      });
    }
  }).catchError((error) {
    if (kDebugMode) {
      print("[Error Generated] : " );
      print(error);
    }
  });

}




startMeeting({
 required String meetingId,
 required String zoomAccessToken,
 required String displayName,

}) {

  ZoomOptions zoomOptions = ZoomOptions(
      domain: "zoom.us",
      jwtToken: generateZoomJWT()
  );
  var meetingOptions = ZoomMeetingOptions(
      meetingId: meetingId,
      zoomAccessToken: zoomAccessToken,
      displayName: displayName,
      disableDialIn: "false",
      disableDrive: "false",
      disableInvite: "false",
      disableShare: "false",
      disableTitlebar: "false",
      viewOptions: "false",
      noAudio: "false",
      noDisconnectAudio: "false");

  var zoom = ZoomView();
  zoom.initZoom(zoomOptions).then((results) {
    if (results[0] == 0) {
      zoom.onMeetingStatus().listen((status) {
        if (kDebugMode) {
          print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
        }
        if (_isMeetingEnded(status[0])) {
          unInitialize();
          if (kDebugMode) {
            print("[Meeting Status] :- Ended");
          }
        }
        if (status[0] == "MEETING_STATUS_INMEETING") {
          zoom.meetinDetails().then((meetingDetailsResult) {
            if (kDebugMode) {
              print("[MeetingDetailsResult] :- " +
                  meetingDetailsResult.toString());
            }
          });
        }
      });
      zoom.startMeeting(meetingOptions).then((loginResult) {
        if (kDebugMode) {
          print("[LoginResult] :- " + loginResult.toString());
        }
        if (loginResult[0] == "SDK ERROR") {
          //SDK INIT FAILED
          if (kDebugMode) {
            print((loginResult[1]).toString());
          }
        } else if (loginResult[0] == "LOGIN ERROR") {
          //LOGIN FAILED - WITH ERROR CODES
          if (kDebugMode) {
            print((loginResult[1]).toString());
          }
        } else {
          //LOGIN SUCCESS & MEETING STARTED - WITH SUCCESS CODE 200
          if (kDebugMode) {
            print((loginResult[0]).toString());
          }
        }
      });
    }
  }).catchError((error) {
    if (kDebugMode) {
      print("[Error Generated] : " );
      print(error);
    }
  });
}

unInitialize() async{
  var zoom = ZoomView();
  await zoom.unInitialize();
}