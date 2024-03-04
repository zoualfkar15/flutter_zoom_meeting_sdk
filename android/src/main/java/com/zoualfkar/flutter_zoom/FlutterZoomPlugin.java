package com.zoualfkar.flutter_zoom;

//import androidx.annotation.NonNull;
//
//import io.flutter.embedding.engine.plugins.FlutterPlugin;
//import io.flutter.plugin.common.MethodCall;
//import io.flutter.plugin.common.MethodChannel;
//import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
//import io.flutter.plugin.common.MethodChannel.Result;
//
///** FlutterZoomPlugin */
//public class FlutterZoomPlugin implements FlutterPlugin, MethodCallHandler {
//  /// The MethodChannel that will the communication between Flutter and native Android
//  ///
//  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
//  /// when the Flutter Engine is detached from the Activity
//  private MethodChannel channel;
//
//  @Override
//  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
//    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_zoom");
//    channel.setMethodCallHandler(this);
//  }
//
//  @Override
//  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//    if (call.method.equals("getPlatformVersion")) {
//      result.success("Android " + android.os.Build.VERSION.RELEASE);
//    } else {
//      result.notImplemented();
//    }
//  }
//
//  @Override
//  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
//    channel.setMethodCallHandler(null);
//  }
//}


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

import us.zoom.sdk.CustomizedNotificationData;
import us.zoom.sdk.InMeetingNotificationHandle;
import us.zoom.sdk.InMeetingService;
import us.zoom.sdk.JoinMeetingOptions;
import us.zoom.sdk.JoinMeetingParams;
import us.zoom.sdk.MeetingService;
import us.zoom.sdk.MeetingStatus;
import us.zoom.sdk.MeetingViewsOptions;
import us.zoom.sdk.StartMeetingOptions;
import us.zoom.sdk.StartMeetingParams4NormalUser;
import us.zoom.sdk.StartMeetingParamsWithoutLogin;
import us.zoom.sdk.ZoomAuthenticationError;
import us.zoom.sdk.ZoomError;
import us.zoom.sdk.ZoomSDK;
import us.zoom.sdk.ZoomSDKAuthenticationListener;
import us.zoom.sdk.ZoomSDKInitParams;
import us.zoom.sdk.ZoomSDKInitializeListener;
import us.zoom.sdk.JoinMeetingParam4WithoutLogin;
import us.zoom.sdk.StartMeetingParams4NormalUser;
import us.zoom.sdk.StartMeetingParamsWithoutLogin;
import us.zoom.sdk.JoinMeetingParam4WithoutLogin;


/**
 * FlutterZoomPlugin
 */
public class FlutterZoomPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

  private final static String TAG = "ZoomLogNative";

  Activity activity;
  private Result pendingResult;

  private MethodChannel methodChannel;
  private Context context;
  private EventChannel meetingStatusChannel;
  private InMeetingService inMeetingService;


  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.zoualfkar/flutter_zoom");
    methodChannel.setMethodCallHandler(this);

    meetingStatusChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "com.zoualfkar/flutter_zoom_event_stream");
  }

  @Override
  public void onMethodCall(@NonNull MethodCall methodCall, @NonNull final Result result) {
    switch (methodCall.method) {
      case "init":
        init(methodCall, result);
        break;
      case "join":
        joinMeeting(methodCall, result);
        break;
      case "startMeeting":
        startMeeting(methodCall, result);
        break;
      case "meeting_status":
        meetingStatus(result);
        break;
      case "meeting_details":
        meetingDetails(result);
        break;
      case "unInitialize":
        unInitialize(methodCall, result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
  }

  private void sendReply(List data) {
    if (this.pendingResult == null) {
      return;
    }
    this.pendingResult.success(data);
    this.clearPendingResult();
  }

  private void clearPendingResult() {
    this.pendingResult = null;
  }

  //Initializing the Zoom SDK for Android
  private void init(final MethodCall methodCall, final Result result) {
    Map<String, String> options = methodCall.arguments();

    ZoomSDK zoomSDK = ZoomSDK.getInstance();

    if (zoomSDK.isInitialized()) {
      List<Integer> response = Arrays.asList(0, 0);
      result.success(response);
      return;
    }

    ZoomSDKInitParams initParams = new ZoomSDKInitParams();
    initParams.jwtToken = options.get("jwtToken");
    initParams.domain = options.get("domain");
    initParams.enableLog = true;

    final InMeetingNotificationHandle handle = (context, intent) -> {
      intent = new Intent(context, FlutterZoomPlugin.class);
      intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
      if (context == null) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      }
      intent.setAction(InMeetingNotificationHandle.ACTION_RETURN_TO_CONF);
      assert context != null;
      context.startActivity(intent);
      return true;
    };

    //Set custom Notification fro android
    final CustomizedNotificationData data = new CustomizedNotificationData();
    data.setContentTitleId(R.string.app_name_zoom_local);
    data.setLargeIconId(R.drawable.zm_mm_type_emoji);
    data.setSmallIconId(R.drawable.zm_mm_type_emoji);
    data.setSmallIconForLorLaterId(R.drawable.zm_mm_type_emoji);

    ZoomSDKInitializeListener listener = new ZoomSDKInitializeListener() {
      /**
       * @param errorCode {@link us.zoom.sdk.ZoomError#ZOOM_ERROR_SUCCESS} if the SDK has been initialized successfully.
       */
      @Override
      public void onZoomSDKInitializeResult(int errorCode, int internalErrorCode) {
        List<Integer> response = Arrays.asList(errorCode, internalErrorCode);

        if (errorCode != ZoomError.ZOOM_ERROR_SUCCESS) {
          System.out.println("Failed to initialize Zoom SDK");
          System.out.println(response);
          result.success(response);
          return;
        }

        ZoomSDK zoomSDK = ZoomSDK.getInstance();
        ZoomSDK.getInstance().getMeetingSettingsHelper().enableShowMyMeetingElapseTime(true);
        ZoomSDK.getInstance().getMeetingSettingsHelper().setCustomizedNotificationData(data, handle);

        MeetingService meetingService = zoomSDK.getMeetingService();
        meetingStatusChannel.setStreamHandler(new StatusStreamHandler(meetingService));
        result.success(response);
      }

      @Override
      public void onZoomAuthIdentityExpired() {
      }
    };
    zoomSDK.initialize(context, listener, initParams);
  }

  //Join Meeting with passed Meeting ID and Passcode
  private void joinMeeting(MethodCall methodCall, Result result) {

    Map<String, String> options = methodCall.arguments();

    ZoomSDK zoomSDK = ZoomSDK.getInstance();
    if (!zoomSDK.isInitialized()) {
      System.out.println("Not initialized!!!!!!");

      result.success(false);
      return;
    } else {
      boolean hideMeetingInviteUrl = parseBoolean(options, "hideMeetingInviteUrl");
      ZoomSDK.getInstance().getZoomUIService().hideMeetingInviteUrl(hideMeetingInviteUrl);
    }

    MeetingService meetingService = zoomSDK.getMeetingService();

    JoinMeetingOptions opts = new JoinMeetingOptions();


    opts.no_invite = parseBoolean(options, "disableInvite");
    opts.no_share = parseBoolean(options, "disableShare");
    opts.no_titlebar = parseBoolean(options, "disableTitlebar");
    opts.no_driving_mode = parseBoolean(options, "disableDrive");
    opts.no_dial_in_via_phone = parseBoolean(options, "disableDialIn");
    opts.no_disconnect_audio = parseBoolean(options, "noDisconnectAudio");
    opts.no_audio = parseBoolean(options, "noAudio");
    opts.meeting_views_options = parseInt(options, "meetingViewOptions", 0);
    boolean view_options = parseBoolean(options, "viewOptions");
    if (view_options) {
      opts.meeting_views_options = MeetingViewsOptions.NO_TEXT_MEETING_ID + MeetingViewsOptions.NO_TEXT_PASSWORD + MeetingViewsOptions.NO_BUTTON_PARTICIPANTS;
    }

    //JoinMeetingParams params = new JoinMeetingParams();
    JoinMeetingParam4WithoutLogin params = new JoinMeetingParam4WithoutLogin();

    params.displayName = options.get("displayName");
    params.meetingNo = options.get("meetingId");
    params.password = options.get("meetingPassword");
    params.zoomAccessToken = options.get("zoomAccessToken");

    //params.
    meetingService.joinMeetingWithParams(context, params, opts);
    result.success(true);
  }





  //Perform start meeting function with logging in to the zoom account (Only for passed meeting id)
  private void startMeeting(final MethodCall methodCall, final Result result) {
    this.pendingResult = result;
    ZoomSDK zoomSDK = ZoomSDK.getInstance();

    if (!zoomSDK.isInitialized()) {
      System.out.println("Not initialized!!!!!!");
      sendReply(Arrays.asList("SDK ERROR", "001"));
      return;
    }
    startMeetingInternal(methodCall);

  }

  private void unInitialize(final MethodCall methodCall, final Result result) {


    ZoomSDK zoomSDK = ZoomSDK.getInstance();
    zoomSDK.uninitialize();
    result.success(true);
  }

  // Meeting ID passed Start Meeting Function called on startMeetingNormal triggered via startMeetingNormal function
  private void startMeetingInternal(MethodCall methodCall) {
    Map<String, String> options = methodCall.arguments();

    ZoomSDK zoomSDK = ZoomSDK.getInstance();

    if (!zoomSDK.isInitialized()) {
      System.out.println("Not initialized!!!!!!");
      sendReply(Arrays.asList("SDK ERROR", "001"));
      return;
    }

    MeetingService meetingService = zoomSDK.getMeetingService();
    if (meetingService == null) {
      return;
    }


    StartMeetingOptions opts = new StartMeetingOptions();
    opts.no_invite = parseBoolean(options, "disableInvite");
    opts.no_share = parseBoolean(options, "disableShare");
    opts.no_driving_mode = parseBoolean(options, "disableDrive");
    opts.no_dial_in_via_phone = parseBoolean(options, "disableDialIn");
    opts.no_disconnect_audio = parseBoolean(options, "noDisconnectAudio");
    opts.no_audio = parseBoolean(options, "noAudio");
    opts.no_titlebar = parseBoolean(options, "disableTitlebar");
    boolean view_options = parseBoolean(options, "viewOptions");
    if (view_options) {
      opts.meeting_views_options = MeetingViewsOptions.NO_TEXT_MEETING_ID + MeetingViewsOptions.NO_TEXT_PASSWORD + MeetingViewsOptions.NO_BUTTON_PARTICIPANTS;
    }

    StartMeetingParamsWithoutLogin params = new StartMeetingParamsWithoutLogin();

    Log.d(TAG, "zoomAccessToken, " + options.get("zoomAccessToken"));
    Log.d(TAG, "displayName, " + options.get("displayName"));
    Log.d(TAG, "meetingNo, " + options.get("meetingId"));

    params.zoomAccessToken = options.get("zoomAccessToken");


    params.userType = MeetingService.USER_TYPE_SSO;
    params.displayName = options.get("displayName");
    params.zoomAccessToken = options.get("zoomAccessToken");
    params.meetingNo =  options.get("meetingId");


    int result =  meetingService.startMeetingWithParams(context, params, opts);
    inMeetingService = zoomSDK.getInMeetingService();
    sendReply(Arrays.asList("MEETING SUCCESS 11", "200",result));

  }

  //Helper Function for parsing string to boolean value
  private boolean parseBoolean(Map<String, String> options, String property) {
    return options.get(property) != null && Boolean.parseBoolean(options.get(property));
  }

  private int parseInt(Map<String, String> options, String property, int defaultValue) {
    return options.get(property) == null ? defaultValue : Integer.parseInt(options.get(property));
  }

  //Get Meeting Details Programmatically after Starting the Meeting
  private void meetingDetails(Result result) {
    ZoomSDK zoomSDK = ZoomSDK.getInstance();

    if (!zoomSDK.isInitialized()) {
      System.out.println("Not initialized!!!!!!");
      result.success(Arrays.asList("MEETING_STATUS_UNKNOWN", "SDK not initialized"));
      return;
    }
    MeetingService meetingService = zoomSDK.getMeetingService();

    if (meetingService == null) {
      result.success(Arrays.asList("MEETING_STATUS_UNKNOWN", "No status available"));
      return;
    }
    MeetingStatus status = meetingService.getMeetingStatus();

    result.success(status != null ? Arrays.asList(inMeetingService.getCurrentMeetingNumber(), inMeetingService.getMeetingPassword()) : Arrays.asList("MEETING_STATUS_UNKNOWN", "No status available"));
  }

  //Listen to meeting status on joinning and starting the mmeting
  private void meetingStatus(Result result) {

    ZoomSDK zoomSDK = ZoomSDK.getInstance();

    if (!zoomSDK.isInitialized()) {
      System.out.println("Not initialized!!!!!!");
      result.success(Arrays.asList("MEETING_STATUS_UNKNOWN", "SDK not initialized"));
      return;
    }
    MeetingService meetingService = zoomSDK.getMeetingService();

    if (meetingService == null) {
      result.success(Arrays.asList("MEETING_STATUS_UNKNOWN", "No status available"));
      return;
    }

    MeetingStatus status = meetingService.getMeetingStatus();
    result.success(status != null ? Arrays.asList(status.name(), "") : Arrays.asList("MEETING_STATUS_UNKNOWN", "No status available"));
  }


  @Override
  public void onDetachedFromActivityForConfigChanges() {
    this.activity = null;
  }

  @Override
  public void onDetachedFromActivity() {
    this.activity = null;
  }
}

