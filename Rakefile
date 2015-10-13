require 'xcjobs'

def destinations
  [ 'name=iPhone 6s,OS=9.0' ]
end

XCJobs::Test.new('test') do |t|
  t.workspace = 'GooglePlacesAutocomplete'
  t.scheme = 'GooglePlacesAutocompleteExample'
  t.configuration = 'Release'
  t.build_dir = 'build'
  t.formatter = 'xcpretty -c'

  destinations.each do |destination|
    t.add_destination(destination)
  end
end
