Pod::Spec.new do |s|
  s.name         = "Xendit"
  s.version      = "2.1.8"
  s.summary      = "Xendit is an API for accepting payments online"
  s.homepage     = "https://www.xendit.co"
  s.license      = "MIT"
  s.author             = { "Juan Gonzalez’" => "juan@xendit.co" }
  s.social_media_url   = "https://www.facebook.com/xendit"
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = '9.0'
  s.swift_versions = ["4", "5"]
  s.source       = { :git => 'https://github.com/xendit/xendit-sdk-ios-src.git', :tag => s.version }
  s.source_files = "Xendit/**/*.{h,m,swift}"
  s.ios.vendored_frameworks = 'CardinalMobile.framework'
  s.pod_target_xcconfig = { 'ONLY_ACTIVE_ARCH' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386' }
end
