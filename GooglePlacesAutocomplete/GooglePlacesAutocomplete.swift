//
//  GooglePlacesAutocomplete.swift
//  GooglePlacesAutocomplete
//
//  Created by Howard Wilson on 10/02/2015.
//  Copyright (c) 2015 Howard Wilson. All rights reserved.
//

import UIKit

public let ErrorDomain: String! = "GooglePlacesAutocompleteErrorDomain"

public struct LocationBias {
  public let latitude: Double
  public let longitude: Double
  public let radius: Int
  
  public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
    self.latitude = latitude
    self.longitude = longitude
    self.radius = radius
  }
  
  public var location: String {
    return "\(latitude),\(longitude)"
  }
}

public enum PlaceType: CustomStringConvertible {
  case all
  case geocode
  case address
  case establishment
  case regions
  case cities

  public var description : String {
    switch self {
      case .all: return ""
      case .geocode: return "geocode"
      case .address: return "address"
      case .establishment: return "establishment"
      case .regions: return "(regions)"
      case .cities: return "(cities)"
    }
  }
}

open class Place: NSObject {
  open let id: String
  open let desc: String
  open var apiKey: String?

  override open var description: String {
    get { return desc }
  }

  public init(id: String, description: String) {
    self.id = id
    self.desc = description
  }

  public convenience init(prediction: [String: AnyObject], apiKey: String?) {
    self.init(
      id: prediction["place_id"] as! String,
      description: prediction["description"] as! String
    )

    self.apiKey = apiKey
  }

  /**
    Call Google Place Details API to get detailed information for this place
  
    Requires that Place#apiKey be set
  
    - parameter result: Callback on successful completion with detailed place information
  */
  open func getDetails(_ result: @escaping (PlaceDetails) -> ()) {
    GooglePlaceDetailsRequest(place: self).request(result)
  }
}

open class PlaceDetails: CustomStringConvertible {
  open let name: String
  open let latitude: Double
  open let longitude: Double
  open let raw: [String: AnyObject]

  public init(json: [String: AnyObject]) {
    let result = json["result"] as! [String: AnyObject]
    let geometry = result["geometry"] as! [String: AnyObject]
    let location = geometry["location"] as! [String: AnyObject]

    self.name = result["name"] as! String
    self.latitude = location["lat"] as! Double
    self.longitude = location["lng"] as! Double
    self.raw = json
  }

  open var description: String {
    return "PlaceDetails: \(name) (\(latitude), \(longitude))"
  }
}

@objc public protocol GooglePlacesAutocompleteDelegate {
  @objc optional func placesFound(_ places: [Place])
  @objc optional func placeSelected(_ place: Place)
  @objc optional func placeViewClosed()
}

// MARK: - GooglePlacesAutocomplete
open class GooglePlacesAutocomplete: UINavigationController {
  open var gpaViewController: GooglePlacesAutocompleteContainer!
  open var closeButton: UIBarButtonItem!

  // Proxy access to container navigationItem
  open override var navigationItem: UINavigationItem {
    get { return gpaViewController.navigationItem }
  }

  open var placeDelegate: GooglePlacesAutocompleteDelegate? {
    get { return gpaViewController.delegate }
    set { gpaViewController.delegate = newValue }
  }
  
  open var locationBias: LocationBias? {
    get { return gpaViewController.locationBias }
    set { gpaViewController.locationBias = newValue }
  }

  public convenience init(apiKey: String, placeType: PlaceType = .all) {
    let gpaViewController = GooglePlacesAutocompleteContainer(
      apiKey: apiKey,
      placeType: placeType
    )

    self.init(rootViewController: gpaViewController)
    self.gpaViewController = gpaViewController

    closeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(GooglePlacesAutocomplete.close))
    closeButton.style = UIBarButtonItemStyle.done

    gpaViewController.navigationItem.leftBarButtonItem = closeButton
    gpaViewController.navigationItem.title = "Enter Address"
  }

  func close() {
    placeDelegate?.placeViewClosed?()
  }

  open func reset() {
    gpaViewController.searchBar.text = ""
    gpaViewController.searchBar(gpaViewController.searchBar, textDidChange: "")
  }
}

// MARK: - GooglePlacesAutocompleteContainer
open class GooglePlacesAutocompleteContainer: UIViewController {
  @IBOutlet open weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var topConstraint: NSLayoutConstraint!

  var delegate: GooglePlacesAutocompleteDelegate?
  var apiKey: String?
  var places = [Place]()
  var placeType: PlaceType = .all
  var locationBias: LocationBias?

  convenience init(apiKey: String, placeType: PlaceType = .all) {
    let bundle = Bundle(for: GooglePlacesAutocompleteContainer.self)

    self.init(nibName: "GooglePlacesAutocomplete", bundle: bundle)
    self.apiKey = apiKey
    self.placeType = placeType
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override open func viewWillLayoutSubviews() {
    topConstraint.constant = topLayoutGuide.length
  }

  override open func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(GooglePlacesAutocompleteContainer.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    searchBar.becomeFirstResponder()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }

  func keyboardWasShown(_ notification: Notification) {
    if isViewLoaded && view.window != nil {
      let info: Dictionary = (notification as NSNotification).userInfo!
      let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
      let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)

      tableView.contentInset = contentInsets;
      tableView.scrollIndicatorInsets = contentInsets;
    }
  }

  func keyboardWillBeHidden(_ notification: Notification) {
    if isViewLoaded && view.window != nil {
      self.tableView.contentInset = UIEdgeInsets.zero
      self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
  }
}

// MARK: - GooglePlacesAutocompleteContainer (UITableViewDataSource / UITableViewDelegate)
extension GooglePlacesAutocompleteContainer: UITableViewDataSource, UITableViewDelegate {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return places.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 

    // Get the corresponding candy from our candies array
    let place = self.places[(indexPath as NSIndexPath).row]

    // Configure the cell
    cell.textLabel!.text = place.description
    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
    
    return cell
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.placeSelected?(self.places[(indexPath as NSIndexPath).row])
  }
}

// MARK: - GooglePlacesAutocompleteContainer (UISearchBarDelegate)
extension GooglePlacesAutocompleteContainer: UISearchBarDelegate {
  public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if (searchText == "") {
      self.places = []
      tableView.isHidden = true
    } else {
      getPlaces(searchText)
    }
  }

  /**
    Call the Google Places API and update the view with results.

    - parameter searchString: The search query
  */
  
  fileprivate func getPlaces(_ searchString: String) {
    var params = [
      "input": searchString,
      "types": placeType.description,
      "key": apiKey ?? ""
    ]
    
    if let bias = locationBias {
      params["location"] = bias.location
      params["radius"] = bias.radius.description
    }
    
    if (searchString == ""){
      return
    }
    
    GooglePlacesRequestHelpers.doRequest(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json",
      params: params
      ) { json, error in
        if let json = json{
          if let predictions = json["predictions"] as? Array<[String: AnyObject]> {
            self.places = predictions.map { (prediction: [String: AnyObject]) -> Place in
              return Place(prediction: prediction, apiKey: self.apiKey)
            }
          self.tableView.reloadData()
          self.tableView.isHidden = false
          self.delegate?.placesFound?(self.places)
        }
      }
    }
  }
}

// MARK: - GooglePlaceDetailsRequest
class GooglePlaceDetailsRequest {
  let place: Place

  init(place: Place) {
    self.place = place
  }

  func request(_ result: @escaping (PlaceDetails) -> ()) {
    GooglePlacesRequestHelpers.doRequest(
      "https://maps.googleapis.com/maps/api/place/details/json",
      params: [
        "placeid": place.id,
        "key": place.apiKey ?? ""
      ]
    ) { json, error in
      if let json = json as? [String: AnyObject] {
        result(PlaceDetails(json: json))
      }
      if let error = error {
        // TODO: We should probably pass back details of the error
        print("Error fetching google place details: \(error)")
      }
    }
  }
}

// MARK: - GooglePlacesRequestHelpers
class GooglePlacesRequestHelpers {
  /**
  Build a query string from a dictionary

  - parameter parameters: Dictionary of query string parameters
  - returns: The properly escaped query string
  */
  fileprivate class func query(_ parameters: [String: AnyObject]) -> String {
    var components: [(String, String)] = []
    for key in Array(parameters.keys).sorted(by: <) {
      let value = parameters[key] as! String
      components += [(escape(key), escape("\(value)"))]
    }

    return (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
  }

  fileprivate class func escape(_ string: String) -> String {
    let legalURLCharactersToBeEscaped: CFString = ":/?&=;+!@#$()',*" as CFString
    return CFURLCreateStringByAddingPercentEscapes(nil, string as CFString!, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
  }

  fileprivate class func doRequest(_ url: String, params: [String: String], completion: @escaping (NSDictionary?,Error?) -> ()) {
    let request = URLRequest(url: URL(string: "\(url)?\(query(params as [String : AnyObject]))")!)
    let session = URLSession.shared
    
    let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
      self.handleResponse(data, response: response as! HTTPURLResponse, error: error, completion: completion)
    }

    task.resume()
  }

  fileprivate class func handleResponse(_ data: Data!, response: HTTPURLResponse!, error: Error!, completion: @escaping (NSDictionary?, Error?) -> ()) {
    
    // Always return on the main thread...
    let done: ((NSDictionary?, Error?) -> Void) = {(json, error) in
        DispatchQueue.main.async(execute: {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            completion(json,error)
        })
    }
    
    if let error = error {
      print("GooglePlaces Error: \(error.localizedDescription)")
      done(nil,error)
      return
    }

    if response == nil {
      print("GooglePlaces Error: No response from API")
      let error = NSError(domain: ErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey:"No response from API"])
      done(nil,error)
      return
    }

    if response.statusCode != 200 {
      print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
      let error = NSError(domain: ErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:"Invalid status code"])
      done(nil,error)
      return
    }
    
    let json: NSDictionary?
    do {
      json = try JSONSerialization.jsonObject(
        with: data,
        options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
    } catch {
      print("Serialisation error")
      let serialisationError = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:"Serialization error"])
      done(nil,serialisationError)
      return
    }

    if let status = json?["status"] as? String {
      if status != "OK" {
        print("GooglePlaces API Error: \(status)")
        let error = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:status])
        done(nil,error)
        return
      }
    }
    
    done(json,nil)

  }
}
