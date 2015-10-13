//
//  GooglePlacesAutocompleteExampleTests.swift
//  GooglePlacesAutocompleteExampleTests
//
//  Created by Howard Wilson on 15/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import GooglePlacesAutocomplete
import FBSnapshotTestCase
import OHHTTPStubs

class GooglePlacesAutocompleteTests: FBSnapshotTestCase, GooglePlacesAutocompleteDelegate {
  let gpaViewController = GooglePlacesAutocomplete(apiKey: "APIKEY")
  var expectation: XCTestExpectation!

  func testGooglePlacesAutocomplete() {
    let json: [String : AnyObject] = ["predictions" : [prediction1, prediction2]]
    expectation = self.expectationWithDescription("Should return results")

    OHHTTPStubs.stubRequestsPassingTest({ (request: NSURLRequest!) -> Bool in
      return request.URL!.absoluteString == "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Paris&key=APIKEY&types="
      }, withStubResponse: { (request: NSURLRequest!) -> OHHTTPStubsResponse in
        return OHHTTPStubsResponse(JSONObject: json, statusCode: 200, headers: nil)
    })

    self.gpaViewController.placeDelegate = self

    UIApplication.sharedApplication().keyWindow!.rootViewController = UIViewController()

    let rootVC = UIApplication.sharedApplication().keyWindow!.rootViewController!

    rootVC.presentViewController(self.gpaViewController, animated: false, completion: {
      self.FBSnapshotVerifyView(self.gpaViewController.view, identifier: "view")

      self.gpaViewController.gpaViewController.searchBar(
        self.gpaViewController.gpaViewController.searchBar,
        textDidChange: "Paris"
      )
    })

    self.waitForExpectationsWithTimeout(2.0, handler: nil)
  }

  func placesFound(places: [Place]) {
    self.FBSnapshotVerifyView(self.gpaViewController.view, identifier: "search")
    expectation.fulfill()
  }

  let prediction1: [String : AnyObject] = [
    "description" : "Paris, France",
    "id" : "691b237b0322f28988f3ce03e321ff72a12167fd",
    "matched_substrings" : [
      ["length" : 5, "offset" : 0]
    ],
    "place_id" : "ChIJD7fiBh9u5kcRYJSMaMOCCwQ",
    "reference" : "CjQlAAAAbHAcwNAV9grGOKRGKz0czmHc_KsFufZ90X7ZhD0aPhWpyTb8-BQqe0GwWGDdGYzbEhBhFHGRSW6t6U8do2RzgUe0GhRZivpe7tNn7ujO7sWz6Vkv9CNyXg",
    "terms" : [
      ["offset" : 0, "value" : "Paris"],
      ["offset" : 7, "value" : "France"]
    ],
    "types" : [ "locality", "political", "geocode" ]
  ]

  let prediction2: [String : AnyObject] = [
    "description" : "Paris 17, Paris, France",
    "id" : "126ccd7b36db3990466ee234998f25ab92ce88ac",
    "matched_substrings" : [
      ["length" : 5, "offset" : 0]
    ],
    "place_id" : "ChIJVRQP1aJv5kcRUBuUaMOCCwU",
    "reference" : "CjQvAAAAR0bndCO53tJbbUDTclTXN6rgKRDEqCmsoYCDq5qpHCnOnhhrtyXmFSwWx-zVvWi0EhD6G6PPrJTOQEazhy5-JFhVGhRND1R7Or4V3lDaHkBcXt98X8u5mw",
    "terms" : [
      ["offset" : 0, "value" : "Paris 17"],
      ["offset" : 10, "value" : "Paris"],
      ["offset" : 17, "value" : "France"]
    ],
    "types" : [ "sublocality_level_1", "sublocality", "political", "geocode" ]
  ]
}
