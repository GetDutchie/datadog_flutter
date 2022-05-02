#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint datadog_flutter.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'datadog_flutter'
  s.version          = '0.0.3'
  s.summary          = 'Log to Datadog from Flutter.'
  s.description      = <<-DESC
Log to Datadog from Flutter.
                       DESC
  s.homepage         = 'https://dutchie.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dutchie' => 'tim.shedor@dutchie.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # https://github.com/flutter/flutter/issues/17978
  s.dependency 'DatadogSDK', '>= 1.8.0'
  # https://github.com/GetDutchie/datadog_flutter/issues/99
  s.dependency 'DatadogSDKCrashReporting', '>= 1.8.0'
  s.dependency 'AnyCodable-FlightSchool', '~> 0.6.0'
end
