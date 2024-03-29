#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_zoom.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_zoom_meeting'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Zoom Meeting SDK'
  s.description      = <<-DESC
Flutter Zoom Meeting SDK
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'zoualfkar@hotmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-framework MobileRTC', 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.preserve_paths = 'MobileRTC.xcframework', 'MobileRTCResources.bundle'
  s.vendored_frameworks = 'MobileRTC.xcframework'
  s.resource = 'MobileRTCResources.bundle'
end
