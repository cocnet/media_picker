#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint multi_image_picker.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'multi_image_picker'
  s.version          = '0.1.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m,mm,swift,c}'
  #s.resource = '**/*.{xib,png,json,mp3,captionstyle,ttf}'
  s.resource_bundles = {'fb_media_editor' => ['**/*.{xib,png,json,mp3,captionstyle,ttf,lic}']}
s.library = 'stdc++'
  s.dependency 'Flutter'
  s.dependency "IQKeyboardManagerSwift", "6.0.4"
  s.dependency 'MBProgressHUD'
  s.dependency 'SDWebImageWebPCoder'
  s.dependency 'SDWebImage'
  s.dependency 'Toast'
  s.dependency 'YYModel'
  s.dependency 'YYCache'
  s.dependency 'FCFileManager' #文件管理
  s.dependency 'CYLTableViewPlaceHolder' #tableview 占位
  s.dependency 'EZAudio', '1.1.2' #录音音频处理
  s.dependency 'JXTAlertManager'
  s.dependency 'JXCategoryView'
  s.dependency 'MJRefresh'
  s.dependency 'AFNetworking'
  s.dependency 'UICKeyChainStore'
  s.dependency 'SDCycleScrollView'
  s.dependency 'SVProgressHUD'
  s.dependency 'DeviceUtil'
  s.dependency 'FCFileManager' #文件管理
  s.dependency 'Masonry'
  s.dependency 'ReactiveObjC', '3.1.1'
  s.dependency  'SSZipArchive'
  s.platform = :ios, '12.0'
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
