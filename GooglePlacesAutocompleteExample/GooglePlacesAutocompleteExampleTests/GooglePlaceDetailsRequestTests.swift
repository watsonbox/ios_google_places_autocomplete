//
//  GooglePlaceDetailsRequestTests.swift
//  GooglePlacesAutocompleteExample
//
//  Created by Howard Wilson on 25/03/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import Foundation
import XCTest
import GooglePlacesAutocomplete
import OHHTTPStubs

class GooglePlaceDetailsRequestTests: XCTestCase {
  let json: [String : AnyObject] = [
    "html_attributions" : [] as AnyObject,
    "result" : [
      "formatted_address" : "48 Pirrama Road, Pyrmont NSW, Australia",
      "formatted_phone_number" : "(02) 9374 4000",
      "geometry" : [
        "location" : [
          "lat" : -33.8669710,
          "lng" : 151.1958750
        ]
      ] as AnyObject,
      "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png",
      "id" : "4f89212bf76dde31f092cfc14d7506555d85b5c7",
      "name" : "Google Sydney"
      // ...
    ] as AnyObject,
    "status" : "OK" as AnyObject
  ]

  func testSuccessfulDetailsRequest() {
    let place = Place(prediction: ["place_id": "691b237b0322f28988f3ce03e321ff72a12167fd" as AnyObject, "description": "Paris, France" as AnyObject], apiKey: "APIKEY")
    let expectation = self.expectation(description: "Should return details")

    OHHTTPStubs.stubRequests(passingTest: { (request: URLRequest!) -> Bool in
      return request.url!.absoluteString == "https://maps.googleapis.com/maps/api/place/details/json?key=APIKEY&placeid=\(place.id)"
      }, withStubResponse: { (request: URLRequest!) -> OHHTTPStubsResponse in
        return OHHTTPStubsResponse(jsonObject: self.json, statusCode: 200, headers: nil)
    })

    place.getDetails { details in
      XCTAssertEqual(details.name, "Google Sydney")
      XCTAssertEqual(details.latitude, -33.8669710)
      XCTAssertEqual(details.longitude, 151.1958750)

      expectation.fulfill()
    }

    self.waitForExpectations(timeout: 2.0, handler: nil)
  }
}
