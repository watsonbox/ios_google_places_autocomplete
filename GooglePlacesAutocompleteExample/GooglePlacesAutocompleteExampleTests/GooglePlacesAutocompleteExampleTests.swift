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
    let json: [String : AnyObject] = ["predictions" : [prediction1, prediction2] as AnyObject]
    expectation = self.expectation(description: "Should return results")

    OHHTTPStubs.stubRequests(passingTest: { (request: URLRequest!) -> Bool in
      return request.url!.absoluteString == "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Paris&key=APIKEY&types="
      }, withStubResponse: { (request: URLRequest!) -> OHHTTPStubsResponse in
        return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
    })

    self.gpaViewController.placeDelegate = self

    UIApplication.shared.keyWindow!.rootViewController = UIViewController()

    let rootVC = UIApplication.shared.keyWindow!.rootViewController!

    rootVC.present(self.gpaViewController, animated: false, completion: {
      self.FBSnapshotVerifyView(self.gpaViewController.view, identifier: "view")

      self.gpaViewController.gpaViewController.searchBar(
        self.gpaViewController.gpaViewController.searchBar,
        textDidChange: "Paris"
      )
    })

    self.waitForExpectations(timeout: 2.0, handler: nil)
  }

  func placesFound(_ places: [Place]) {
    self.FBSnapshotVerifyView(self.gpaViewController.view, identifier: "search")
    expectation.fulfill()
  }

  let prediction1: [String : AnyObject] = [
    "description" : "Paris, France" as AnyObject,
    "id" : "691b237b0322f28988f3ce03e321ff72a12167fd" as AnyObject,
    "matched_substrings" : [
      ["length" : 5, "offset" : 0]
    ] as AnyObject,
    "place_id" : "ChIJD7fiBh9u5kcRYJSMaMOCCwQ" as AnyObject,
    "reference" : "CjQlAAAAbHAcwNAV9grGOKRGKz0czmHc_KsFufZ90X7ZhD0aPhWpyTb8-BQqe0GwWGDdGYzbEhBhFHGRSW6t6U8do2RzgUe0GhRZivpe7tNn7ujO7sWz6Vkv9CNyXg" as AnyObject,
    "terms" : [
      ["offset" : 0, "value" : "Paris"],
      ["offset" : 7, "value" : "France"]
    ] as AnyObject,
    "types" : [ "locality", "political", "geocode" ] as AnyObject
  ]

  let prediction2: [String : AnyObject] = [
    "description" : "Paris 17, Paris, France" as AnyObject,
    "id" : "126ccd7b36db3990466ee234998f25ab92ce88ac" as AnyObject,
    "matched_substrings" : [
      ["length" : 5, "offset" : 0]
    ] as AnyObject,
    "place_id" : "ChIJVRQP1aJv5kcRUBuUaMOCCwU" as AnyObject,
    "reference" : "CjQvAAAAR0bndCO53tJbbUDTclTXN6rgKRDEqCmsoYCDq5qpHCnOnhhrtyXmFSwWx-zVvWi0EhD6G6PPrJTOQEazhy5-JFhVGhRND1R7Or4V3lDaHkBcXt98X8u5mw" as AnyObject,
    "terms" : [
      ["offset" : 0, "value" : "Paris 17"],
      ["offset" : 10, "value" : "Paris"],
      ["offset" : 17, "value" : "France"]
    ] as AnyObject,
    "types" : [ "sublocality_level_1", "sublocality", "political", "geocode" ] as AnyObject
  ]
}
