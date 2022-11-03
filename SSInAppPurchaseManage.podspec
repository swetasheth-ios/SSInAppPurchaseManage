#
# Be sure to run `pod lib lint SSInAppPurchaseManage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SSInAppPurchaseManage'
  s.version          = '0.1.0'
  s.summary          = 'In App purchase product management library.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/swetasheth-ios/SSInAppPurchaseManage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'swetasheth-ios' => 'swetasheth.ios@gmail.com' }
  s.source           = { :git => 'https://github.com/swetasheth-ios/SSInAppPurchaseManage.git', :tag => s.version.to_s }
   s.social_media_url = 'https://twitter.com/Swetasheth_ios'

  s.swift_version = '5.1'
  s.ios.deployment_target = '10.0'

  s.source_files = 'SSInAppPurchaseManage/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SSInAppPurchaseManage' => ['SSInAppPurchaseManage/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'SwiftyStoreKit'
end
