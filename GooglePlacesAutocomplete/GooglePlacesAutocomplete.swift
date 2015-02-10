//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit
import Alamofire

enum PlaceType: Printable {
  case All
  case Geocode
  case Address
  case Establishment
  case Regions
  case Cities

  var description : String {
    switch self {
    case .All: return ""
    case .Geocode: return "geocode"
    case .Address: return "address"
    case .Establishment: return "establishment"
    case .Regions: return "regions"
    case .Cities: return "cities"
    }
  }
}

struct Place {
  let id: String
  let description: String
}

protocol GooglePlacesAutocompleteDelegate {
  func placeSelected(place: Place)
  func placeViewClosed()
}

// MARK: - GooglePlacesAutocomplete
class GooglePlacesAutocomplete: UINavigationController {
  var gpaViewController: GooglePlacesAutocompleteContainer?

  var placeDelegate: GooglePlacesAutocompleteDelegate? {
    get { return gpaViewController?.delegate }
    set { gpaViewController?.delegate = newValue }
  }

  convenience init(apiKey: String, placeType: PlaceType = .All) {
    let gpaViewController = GooglePlacesAutocompleteContainer(
      apiKey: apiKey,
      placeType: placeType
    )

    self.init(rootViewController: gpaViewController)
    self.gpaViewController = gpaViewController

    let closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "close")

    gpaViewController.navigationItem.leftBarButtonItem = closeButton
    gpaViewController.navigationItem.title = "Enter Address"
  }

  func close() {
    placeDelegate?.placeViewClosed()
  }
}

// MARK: - GooglePlaceSearchDisplayController
class GooglePlaceSearchDisplayController: UISearchDisplayController {
  override func setActive(visible: Bool, animated: Bool) {
    if active == visible { return }

    searchContentsController.navigationController?.navigationBarHidden = true
    super.setActive(visible, animated: animated)

    searchContentsController.navigationController?.navigationBarHidden = false

    if visible {
      searchBar.becomeFirstResponder()
    } else {
      searchBar.resignFirstResponder()
    }
  }
}

// MARK: - GooglePlacesAutocompleteContainer
class GooglePlacesAutocompleteContainer: UIViewController {
  var delegate: GooglePlacesAutocompleteDelegate?
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

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
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

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    delegate?.placeSelected(self.places[indexPath.row])
  }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchDisplayDelegate)
extension GooglePlacesAutocompleteContainer: UISearchDisplayDelegate {
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
