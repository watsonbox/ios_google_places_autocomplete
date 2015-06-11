Pod::Spec.new do |spec|
  spec.name = "GooglePlacesAutocomplete"
  spec.version = "0.3.0"
  spec.summary = "Simple Google Places autocompleting address entry view"
  spec.homepage = "https://github.com/watsonbox/ios_google_places_autocomplete"
  spec.screenshots = "https://raw.githubusercontent.com/watsonbox/ios_google_places_autocomplete/master/Screenshots/view.png", "https://raw.githubusercontent.com/watsonbox/ios_google_places_autocomplete/master/Screenshots/search.png"
  spec.license = 'MIT'
  spec.author = { "Howard Wilson" => "howard@watsonbox.net" }
  spec.source = { :git => "https://github.com/watsonbox/ios_google_places_autocomplete.git", :tag => spec.version.to_s }
  spec.platform = :ios, '8.0'
  spec.source_files = 'GooglePlacesAutocomplete/*.{h,swift}'
  spec.resources = 'GooglePlacesAutocomplete/*.{xcassets,xib}'
  spec.requires_arc = true
  spec.frameworks = 'UIKit'
end
