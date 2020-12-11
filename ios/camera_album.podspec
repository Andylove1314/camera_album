#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint camera_album.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'camera_album'
  s.version          = '0.0.1'
  s.summary          = '原生相机相册插件'
  s.description      = <<-DESC
原生相机相册插件
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.resource = 'Resources/Gallery.bundle'
  s.dependency 'Flutter'
  s.dependency 'MBProgressHUD', '~> 1.2.0'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
