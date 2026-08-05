#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_inappwebview_forge_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_inappwebview_forge_ios'
  s.version          = '1.0.0'
  s.summary          = 'Maintained Flutter InAppWebView fork for iOS.'
  s.description      = <<-DESC
Maintained fork of Flutter InAppWebView, originally created by Lorenzo Pichilli.
                       DESC
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Emirkan Acar; originally Lorenzo Pichilli' => 'https://github.com/emirkanacar/flutter_inappwebview' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/**/*.swift'
  s.resources = 'flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/Resources/**/*.storyboard'
  s.dependency 'Flutter'
  s.resource_bundles = {'flutter_inappwebview_forge_ios_privacy' => ['flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/Resources/PrivacyInfo.xcprivacy']}

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.libraries = 'swiftCoreGraphics'
  
  s.dependency 'swift-collections', '~>1.3.0'

  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }

  s.swift_version = '5.0'

  s.platforms = { :ios => '12.0' }

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.platform = :ios, '12.0'
  end
end
