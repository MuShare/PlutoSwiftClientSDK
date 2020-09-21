#
# Be sure to run `pod lib lint MuShare-Login-Swift-SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PlutoSDK'
  s.version          = '0.5.2'
  s.summary          = 'Swift SDK for Pluto login microservice.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Swift SDK for Pluto login microservice, which simplify the implementation for signing in with email, Google and Apple.
                       DESC

  s.homepage         = 'https://github.com/MuShare/Pluto-Swift-SDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lm2343635' => 'lm2343635@126.com' }
  s.source           = { :git => 'https://github.com/MuShare/Pluto-Swift-SDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'Pluto/Classes/Core/**/*'
    core.dependency 'Alamofire', '~> 5'
    core.dependency 'SwiftyJSON', '~> 5'
    core.dependency 'SwiftyUserDefaults', '~> 5'
  end

  s.subspec 'Rx' do |rx|
    rx.source_files = 'Pluto/Classes/Rx/**/*'
    rx.dependency 'PlutoSDK/Core', '~> 0'
    rx.dependency 'RxCocoa', '~> 5'
  end
end
