//
//  ViewController.swift
//  GooglePlacesAutocompleteExample
//
//  Created by Howard Wilson on 15/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit
import GooglePlacesAutocomplete

class ViewController: UIViewController {
  let gpaViewController = GooglePlacesAutocomplete(
    apiKey: "AIzaSyDUa_LZCLA1YE5V2kN4VIe3a8RKKM3oDjs",
    placeType: .all,
    extraParam: [["components":"country:in"]]
  )

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    gpaViewController.placeDelegate = self

    present(gpaViewController, animated: true, completion: nil)
  }
}

extension ViewController: GooglePlacesAutocompleteDelegate {
  func placeSelected(_ place: Place) {
    print(place.description)

    place.getDetails { details in
      print(details)
    }
  }

  func placeViewClosed() {
    dismiss(animated: true, completion: nil)
  }
}
