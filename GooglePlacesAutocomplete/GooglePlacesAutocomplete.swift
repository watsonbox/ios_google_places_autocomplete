//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit
import Alamofire

class GooglePlacesAutocomplete: UIViewController {
  var apiKey: String?
  var places = [Place]()
  var placeType: PlaceType = .All

  convenience init(apiKey: String, placeType: PlaceType = .All) {
    self.init(nibName: "GooglePlacesAutocomplete", bundle: nil)
    self.apiKey = apiKey
    self.placeType = placeType
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let tv: UITableView? = searchDisplayController?.searchResultsTableView
    tv?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }
}

extension GooglePlacesAutocomplete: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = self.searchDisplayController?.searchResultsTableView?.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

    // Get the corresponding candy from our candies array
    let place = self.places[indexPath.row]

    // Configure the cell
    cell.textLabel!.text = place.description
    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    
    return cell
  }
}

extension GooglePlacesAutocomplete: UISearchDisplayDelegate {
  func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
    getPlaces(searchString)
    return false
  }

  private func getPlaces(searchString: String) {
    Alamofire.request(.GET,
      "https://maps.googleapis.com/maps/api/place/autocomplete/json",
      parameters: [
        "input": searchString,
        "type": "(\(placeType.description))",
        "key": apiKey ?? ""
      ]).responseJSON { request, response, json, error in
        if let response = json as? NSDictionary {
          if let predictions = response["predictions"] as? Array<AnyObject> {
            self.places = predictions.map { (prediction: AnyObject) -> Place in
              return Place(
                id: prediction["id"] as String,
                description: prediction["description"] as String
              )
            }
          }
        }

        self.searchDisplayController?.searchResultsTableView?.reloadData()
    }
  }
}
