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

    presentViewController(gpaViewController, animated: false, completion: nil)
  }
}
