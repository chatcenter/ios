Pod::Spec.new do |s|
  s.name         = "ChatCenterSDK"
  s.authors      = "AppSocially Inc."
  s.homepage     = "http://chatcenter.io"
  s.version      = "1.1.6"  
  s.ios.deployment_target  = '8.1'
  s.summary      = "ChatCenterSDK: SDK for ChatCenter iO"
  s.description  = "ChatCenter iO helps your business"
  # We can delete the entry "OpenTok" and the followings once Cocoapods allow the dependency to OpenTok
  s.frameworks   = "Foundation", "UIKit", "QuartzCore", "Security", "Social", "MobileCoreServices", "SystemConfiguration", "CoreGraphics", "MessageUI", "CoreLocation", "MapKit", "AssetsLibrary", "SafariServices", "CoreData", "AudioToolbox", "CFNetwork", "OpenTok", "GLKit", "VideoToolbox", "CoreTelephony", "GoogleMaps", "GooglePlaces", "GooglePlacePicker", "GoogleMapsBase"
  s.weak_framework = "UserNotifications", "UserNotificationsUI"
  # These library specifications(c++, icucore) also aren't needed if Cocoapods allows the dependency to OpenTok
  s.library = "c++", "icucore"
  s.source       = { :git => "https://github.com/chatcenter/ios.git" }
  s.source_files = "ChatCenterSDK/*.{h,m}", "ChatCenterSDK/Vendor/**/*.{h,m}"
  s.public_header_files = "ChatCenterSDK/*.h"
  s.xcconfig = {'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}"/OpenTok "${PODS_ROOT}"/GoogleMaps "${PODS_ROOT}"/GooglePlaces "${PODS_ROOT}"/GooglePlacePicker' }
  s.resources = ['ChatCenterSDK/*.{storyboard,xib,png,bundle,xcdatamodeld,xcassets,plist}', '*.lproj', 'TwitterCore.framework', 'TwitterKit.framework', "ChatCenterSDK/Vendor/**/*.{xib,png,bundle}"]
  s.resource_bundle = {
  	'ChatCenter' => ['ChatCenterSDK/*.{storyboard,xib,png,bundle,xcdatamodeld,xcassets,plist}', '*.lproj', "ChatCenterSDK/Vendor/**/*.{xib,png,bundle}"]
  }
  s.prefix_header_file = "ChatCenterSDK/ChatCenter.pch"
  s.pod_target_xcconfig = {'CLANG_ENABLE_MODULES' => 'NO'}
  # So far Cocoapods doesn't allow setting the dependency to OpenTok because it includes a static library.
  #  s.dependency 'OpenTok'
end
