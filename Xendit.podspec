Pod::Spec.new do |s|
  s.name         = "Xendit"
  s.version      = "1.1.2"
  s.summary      = "Xendit is an API for accepting payments online"
  s.homepage     = "https://www.xendit.co"
  s.license      = "MIT"
  s.author             = { "Juan Gonzalez’" => "juan@xendit.co" }
  s.social_media_url   = "https://www.facebook.com/xendit"
  s.source       = { :git => "https://github.com/xendit/xendit-sdk-ios-src.git", :tag => s.version }
  s.source_files = "Xendit/**/*.swift"
  s.ios.deployment_target = "8.0"
end
