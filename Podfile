workspace 'GooglePlacesAutocomplete'

platform :ios, '8.0'

use_frameworks!

target 'GooglePlacesAutocomplete' do
  project 'GooglePlacesAutocomplete.xcodeproj'
end

target 'GooglePlacesAutocompleteTests' do
  project 'GooglePlacesAutocomplete.xcodeproj'
end

target 'GooglePlacesAutocompleteExample' do
  project 'GooglePlacesAutocompleteExample/GooglePlacesAutocompleteExample.xcodeproj'
end

target 'GooglePlacesAutocompleteExampleTests' do
  project 'GooglePlacesAutocompleteExample/GooglePlacesAutocompleteExample.xcodeproj'

  pod 'OHHTTPStubs', '~> 4.3'
  pod 'FBSnapshotTestCase', :git => 'https://github.com/facebook/ios-snapshot-test-case.git', :branch => 'swift-beta-3'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
