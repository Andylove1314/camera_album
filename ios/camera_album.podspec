#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint camera_album.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'camera_album'
  s.version          = '0.0.1'
  s.summary          = '原生相机相册插件'
  s.description      = <<-DESC
原生相机相册插件 ZLPhotoBrowser 4.1.1
https://github.com/longitachi/ZLPhotoBrowser
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.resources        = ['Resources/*.bundle']
  s.dependency 'Flutter'
  s.platform         = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = ['5.0', '5.1', '5.2']
end
