
# Flutter Zoom Meeting SDK

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

#### This plugin relies on the [Flutter_Zoom](https://pub.dev/packages/flutter_zoom_sdk) package. It was developed to address issues encountered with it's functionality.


A Flutter plugin for the Zoom SDK With all features and null safety support.

*Note*: This plugin is still under active development, and some Zoom features might not be available yet.

*Note*: This plugin is work with ZAK token so we need to implement the api to generate ZAK token, All APIs you need are implemented in example .
```  
  
## Features  
  
- [x] Updated Zoom SDK to latest.  
- [x] Null Safety.  
- [x] Stream meeting status.  
- [x] Start an meeting and join meeting with Meeeting ID.  
- [x] iOS Support.  
  
## Zoom SDK Versions  
  
*Note*: Updated to new sdk with new features.  
  

``` 

## Installation

First, add flutter_zoom_meeting` as a dependency in your pubspec.yaml file

After running pub get, you must run the follow script to get Zoom SDK for the first time:

Download sdk files from google drive then find flutter_zoom_meeting path your pc the add files in following paths

Android Files :  
flutter_zoom_meeting/android/libs/

Ios Files :  
flutter_zoom_meeting/android/libs/

Google drive [link](https://drive.google.com/file/d/13w9x1gipnG7E2I3RwM3IWCZ9Ff-vEoZH/view?usp=sharing)


### iOS
Add two rows to the `ios/Runner/Info.plist`:

- one with the key `Privacy - Camera Usage Description` and a usage description.
- and one with the key `Privacy - Microphone Usage Description` and a usage description.

Or in text format add the key:

```xml  
<key>NSCameraUsageDescription</key>  
<string>Need to use the camera for call</string>  
<key>NSMicrophoneUsageDescription</key>  
<string>Need to use the microphone for call</string>  
```  


Disable BITCODE in the `ios/Podfile`:

```  
post_install do |installer|  
installer.pods_project.targets.each do |target|  
flutter_additional_ios_build_settings(target)  
target.build_configurations.each do |config|  
config.build_settings['ENABLE_BITCODE'] = 'NO'  
end  
end  
end  
```  

### Android

Change the minimum Android sdk version to at the minimum 24 in your `android/app/build.gradle` file.

```  
minSdkVersion 24  
```  


Disable shrinkResources for release buid
```  
buildTypes {  
release {  
// TODO: Add your own signing config for the release build.  
// Signing with the debug keys for now, so `flutter run --release` works.  
signingConfig signingConfigs.debug  
shrinkResources false  
}  
}  
```  


## Integration Guide


1. Create Account in [Zoom Market Place](https://marketplace.zoom.us).
2. Create Server-to-Server OAuth then copy the credentials to example/lib/zoom/config.dart
3. Create General App then copy the credentials to example/lib/zoom/config.dart
4. Some APIs, such as generating JWT tokens, ZAK tokens, and creating meetings, may require implementation on the backend side. However, it's up to you where you choose to implement them. All APIs are demonstrated in the provided example.