#import "FlutterZoomPlugin.h"
#if __has_include(<flutter_zoom_meeting/flutter_zoom_meeting-Swift.h>)
#import <flutter_zoom_meeting/flutter_zoom_meeting-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_zoom_meeting-Swift.h"
#endif

@implementation FlutterZoomPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [FlutterZoomPluginService registerWithRegistrar:registrar];
}
@end
