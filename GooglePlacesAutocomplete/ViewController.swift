//
//  ViewController.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let gpaViewController = GooglePlacesAutocomplete(
      apiKey: "[YOUR GOOGLE PLACES API KEY]",
      placeType: .Address
    )

    gpaViewController.placeDelegate = self

    presentViewController(gpaViewController, animated: true, completion: nil)
  }
}

extension ViewController: GooglePlacesAutocompleteDelegate {
  func placeSelected(place: Place) {
    println(place.description)
  }

  func placeViewClosed() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
