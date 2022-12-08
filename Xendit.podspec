Pod::Spec.new do |s|
  s.name             = 'Xendit'
  s.version          = '3.6.1'
  s.license          = 'MIT'
  s.homepage         = 'https://www.xendit.co'
  s.author           = { 'Juan Gonzalez’' => 'juan@xendit.co' }
  s.social_media_url = 'https://www.facebook.com/xendit'
  s.summary          = 'Xendit is an API for accepting payments online'
  s.source           = { :git => 'https://github.com/xendit/xendit-sdk-ios-src.git', :tag => s.version }
  s.swift_versions   = ['4', '5']

  s.platform              = :ios, '9.0'
  s.ios.deployment_target = '9.0'

  s.source_files = 'Sources/**/*.{h,m,swift}'

  s.ios.vendored_frameworks = 'CardinalMobile.xcframework'

  s.pod_target_xcconfig  = { 'ONLY_ACTIVE_ARCH' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
