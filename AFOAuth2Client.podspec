Pod::Spec.new do |s|
  s.name         = "AFOAuth2Client"
  s.version      = "0.1.2"
  s.summary      = "OAuth2 client for AFNetworking."
  s.homepage     = "https://github.com/AFNetworking/AFOAuth2Client"
  s.license      = 'MIT'
  s.authors          = { 'Mattt Thompson' => 'm@mattt.me' }
  s.source   = { :git => 'https://github.com/AFNetworking/AFOAuth2Client.git', :tag => "0.1.2" }
  s.requires_arc = true

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  
  s.public_header_files = 'AFOAuth2Client/*.h'
  s.source_files = 'AFOAuth2Client/AFOAuth2Client.h'
  s.dependency 'AFNetworking', '~> 2.0.3'

end
