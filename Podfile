workspace 'GooglePlacesAutocomplete'

platform :ios, '8.0'

use_frameworks!

target 'GooglePlacesAutocomplete' do
  xcodeproj 'GooglePlacesAutocomplete.xcodeproj'
end

target 'GooglePlacesAutocompleteTests' do
  xcodeproj 'GooglePlacesAutocomplete.xcodeproj'

end

target 'GooglePlacesAutocompleteExample' do
  xcodeproj 'GooglePlacesAutocompleteExample/GooglePlacesAutocompleteExample.xcodeproj'

end

target 'GooglePlacesAutocompleteExampleTests' do
  xcodeproj 'GooglePlacesAutocompleteExample/GooglePlacesAutocompleteExample.xcodeproj'

  pod 'OHHTTPStubs', '~> 4.3'
  pod 'FBSnapshotTestCase', git: "git@github.com:facebook/ios-snapshot-test-case.git"
end
