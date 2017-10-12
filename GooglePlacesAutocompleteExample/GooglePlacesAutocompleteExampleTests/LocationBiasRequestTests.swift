//
//  GooglePlacesLocationBiasRequestTests.swift
//  GooglePlacesAutocompleteExample
//
//  Created by Howard Wilson on 29/06/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import Foundation
import XCTest
import GooglePlacesAutocomplete
import OHHTTPStubs

class LocationBiasRequestTests: XCTestCase, GooglePlacesAutocompleteDelegate {
  let gpaViewController = GooglePlacesAutocomplete(apiKey: "APIKEY")
  var expectation: XCTestExpectation!
  
  func testLocationBiasRequest() {
    expectation = self.expectation(description: "Should return biased results")
    
    OHHTTPStubs.stubRequests(passingTest: { (request: URLRequest!) -> Bool in
      return request.url!.absoluteString == "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Paris&key=APIKEY&location=48.8534275%2C2.35827879999999&radius=1000&types="
      }, withStubResponse: { (request: URLRequest!) -> OHHTTPStubsResponse in
        return OHHTTPStubsResponse(
          jsonObject: ["predictions" : [[
            "description" : "Paris, France",
            "place_id" : "ChIJD7fiBh9u5kcRYJSMaMOCCwQ"
          ]]],
          statusCode: 200, headers: nil)
    })
    
    self.gpaViewController.placeDelegate = self
    self.gpaViewController.locationBias = LocationBias(latitude: 48.8534275, longitude: 2.3582787999999937, radius: 1000)
    
    UIApplication.shared.keyWindow!.rootViewController = UIViewController()
    
    let rootVC = UIApplication.shared.keyWindow!.rootViewController!
    
    rootVC.present(self.gpaViewController, animated: false, completion: {
      self.gpaViewController.gpaViewController.searchBar(
        self.gpaViewController.gpaViewController.searchBar,
        textDidChange: "Paris"
      )
    })
    
    self.waitForExpectations(timeout: 2.0, handler: nil)
  }
  
  func placesFound(_ places: [Place]) {
    expectation.fulfill()
  }
}
