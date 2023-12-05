Pod::Spec.new do |s|
s.name             = "TIPorkSwift"
s.version          = "0.0.1"
s.summary          = "Video Player Using Swift, based on AVPlayer"
s.swift_versions   = "5"
s.description      = <<-DESC
Video Player Using Swift, based on AVPlayer, support for the horizontal screen, vertical screen, the upper and lower slide to adjust the volume, the screen brightness, or so slide to adjust the playback progress.
DESC

s.homepage         = "https://github.com/KyleWhale/TIPorkSwift.git"

s.license          = 'MIT'
s.author           = { "Eliyar Eziz" => "eliyar917@gmail.com" }
s.source           = { :git => "https://github.com/KyleWhale/TIPorkSwift.git", :tag => s.version.to_s }
s.social_media_url = 'http://weibo.com/536445669'

s.ios.deployment_target = '11.0'
s.platform     = :ios, '11.0'
s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

s.source_files = 'Source/*.swift'
s.resources    = "Source/**/*.xcassets"
s.frameworks   = 'UIKit', 'AVFoundation'
s.dependency 'Alamofire'
s.dependency 'SnapKit', '~> 5.0.0'
s.dependency 'NVActivityIndicatorView', '~> 4.7.0'
s.dependency 'Zip'
s.dependency 'LQGConstant'

end
