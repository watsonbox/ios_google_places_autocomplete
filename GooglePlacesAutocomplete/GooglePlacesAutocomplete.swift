//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit

public enum PlaceType: Printable {
  case All
  case Geocode
  case Address
  case Establishment
  case Regions
  case Cities

  public var description : String {
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

public class Place: NSObject {
  public let id: String
  public let desc: String

  override public var description: String {
    get { return desc }
  }

  init(id: String, description: String) {
    self.id = id
    self.desc = description
  }
}

@objc public protocol GooglePlacesAutocompleteDelegate {
  optional func placesFound(places: [Place])
  optional func placeSelected(place: Place)
  optional func placeViewClosed()
}

// MARK: - GooglePlacesAutocomplete
public class GooglePlacesAutocomplete: UINavigationController {
  public var gpaViewController: GooglePlacesAutocompleteContainer!
  public var closeButton: UIBarButtonItem!

  public var placeDelegate: GooglePlacesAutocompleteDelegate? {
    get { return gpaViewController.delegate }
    set { gpaViewController.delegate = newValue }
  }

  public convenience init(apiKey: String, placeType: PlaceType = .All) {
    let gpaViewController = GooglePlacesAutocompleteContainer(
      apiKey: apiKey,
      placeType: placeType
    )

    self.init(rootViewController: gpaViewController)
    self.gpaViewController = gpaViewController

    closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "close")

    gpaViewController.navigationItem.leftBarButtonItem = closeButton
    gpaViewController.navigationItem.title = "Enter Address"
  }

  func close() {
    placeDelegate?.placeViewClosed?()
  }
}

// MARK: - GooglePlacesAutocompleteContainer
public class GooglePlacesAutocompleteContainer: UIViewController {
  @IBOutlet public weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var topConstraint: NSLayoutConstraint!

  var delegate: GooglePlacesAutocompleteDelegate?
  var apiKey: String?
  var places = [Place]()
  var placeType: PlaceType = .All

  convenience init(apiKey: String, placeType: PlaceType = .All) {
    let bundle = NSBundle(forClass: GooglePlacesAutocompleteContainer.self)

    self.init(nibName: "GooglePlacesAutocomplete", bundle: bundle)
    self.apiKey = apiKey
    self.placeType = placeType
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override public func viewWillLayoutSubviews() {
    topConstraint.constant = topLayoutGuide.length
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)

    searchBar.becomeFirstResponder()
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }

  func keyboardWasShown(notification: NSNotification) {
    if isViewLoaded() && view.window != nil {
      let info: Dictionary = notification.userInfo!
      let keyboardSize: CGSize = (info[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size)!
      let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)

      tableView.contentInset = contentInsets;
      tableView.scrollIndicatorInsets = contentInsets;
    }
  }

  func keyboardWillBeHidden(notification: NSNotification) {
    if isViewLoaded() && view.window != nil {
      self.tableView.contentInset = UIEdgeInsetsZero
      self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
  }
}

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
  public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }

  public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

    // Get the corresponding candy from our candies array
    let place = self.places[indexPath.row]

    // Configure the cell
    cell.textLabel!.text = place.description
    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    
    return cell
  }

  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    delegate?.placeSelected?(self.places[indexPath.row])
  }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
  public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if (searchText == "") {
      self.places = []
      tableView.hidden = true
    } else {
      getPlaces(searchText)
    }
  }

  /**
    Call the Google Places API and update the view with results.

    :param: searchString The search query
  */
  private func getPlaces(searchString: String) {
    var request = requestForSearch(searchString)
    var session = NSURLSession.sharedSession()
    var task = session.dataTaskWithRequest(request) { data, response, error in
      self.handleResponse(data, response: response as? NSHTTPURLResponse, error: error)
    }

    task.resume()
  }

  private func handleResponse(data: NSData!, response: NSHTTPURLResponse!, error: NSError!) {
    if let error = error {
      println("GooglePlacesAutocomplete Error: \(error.localizedDescription)")
      return
    }

    if response == nil {
      println("GooglePlacesAutocomplete Error: No response from API")
      return
    }

    if response.statusCode != 200 {
      println("GooglePlacesAutocomplete Error: Invalid status code \(response.statusCode) from API")
      return
    }

    var serializationError: NSError?
    var json: NSDictionary = NSJSONSerialization.JSONObjectWithData(
      data,
      options: NSJSONReadingOptions.MutableContainers,
      error: &serializationError
    ) as NSDictionary

    if let error = serializationError {
      println("GooglePlacesAutocomplete Error: \(error.localizedDescription)")
      return
    }

    // Perform table updates on UI thread
    dispatch_async(dispatch_get_main_queue(), {
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false

      if let predictions = json["predictions"] as? Array<AnyObject> {
        self.places = predictions.map { (prediction: AnyObject) -> Place in
          return Place(
            id: prediction["id"] as String,
            description: prediction["description"] as String
          )
        }

        self.tableView.reloadData()
        self.tableView.hidden = false
        self.delegate?.placesFound?(self.places)
      }
    })
  }

  private func requestForSearch(searchString: String) -> NSURLRequest {
    let params = [
      "input": searchString,
      "type": "(\(placeType.description))",
      "key": apiKey ?? ""
    ]

    return NSMutableURLRequest(
      URL: NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?\(query(params))")!
    )
  }

  /**
    Build a query string from a dictionary

    :param: parameters Dictionary of query string parameters
    :returns: The properly escaped query string
  */
  private func query(parameters: [String: AnyObject]) -> String {
    var components: [(String, String)] = []
    for key in sorted(Array(parameters.keys), <) {
      let value: AnyObject! = parameters[key]
      components += [(escape(key), escape("\(value)"))]
    }

    return join("&", components.map{"\($0)=\($1)"} as [String])
  }

  private func escape(string: String) -> String {
    let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
    return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue)
  }
}
