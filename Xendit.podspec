Pod::Spec.new do |s|
  s.name         = "Xendit"
  s.version      = "0.1.0"
  s.summary      = "Xendit is an API for accepting payments online"
  s.homepage     = "https://www.xendit.co"
  s.license      = "MIT"
  s.author             = { "Juan Gonzalez’" => "juan@xendit.co" }
  s.social_media_url   = "https://www.facebook.com/xendit"
  s.platform     = :ios, "8.0"
  s.source       = { :git => 'https://github.com/xendit/xendit-sdk-ios.git', :tag => s.version }
  s.ios.vendored_frameworks = 'Xendit.framework'
end
