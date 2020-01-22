Pod::Spec.new do |s|
  s.name             = 'SwiftScraper'
  s.version          = '0.3.1'
  s.summary          = 'Screen scraping orchestration for iOS in Swift.'
  s.description      = <<-DESC
Framework that makes it easy to integrate and orchestrate screen scraping with your Swift iOS app.
                       DESC

  s.homepage         = 'https://github.com/saravudh/SwiftScraper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'saravudh' => '2saravudh@gmail.com' }
  s.source           = { :git => 'https://github.com/saravudh/SwiftScraper.git', :tag => s.version.to_s }
  s.resource_bundles = { "SwiftScraper" => ["Resources/**/*.{js}"] }
  s.ios.deployment_target = '8.0'
  s.source_files = 'Sources/**/*.{h,m,swift}'
  s.frameworks = 'UIKit', 'WebKit'
  s.dependency 'KVOSwift'
end
