//
//  LocationPickerViewController.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 7/29/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

public class LocationPickerViewController: UIViewController {
	struct CurrentLocationListener {
		let context: AnyObject?
		let once: Bool
		let action: (CLLocation) -> ()
	}
	
	public var completion: (Location? -> ())?
	
	// region distance to be used for creation region when user selects place from search results
	lazy public var resultRegionDistance: CLLocationDistance = 600
	
	/// default: false
	public var showCurrentLocationButton = false
	
	/// default: true
	public var showCurrentLocationInitially = true
	
	/// see region property of MKLocalSearchRequest
	/// default: false
	public var useCurrentLocationAsHint = false
	
	/// default: "Search or enter an address"
	public var searchBarPlaceholder = "Search or enter an address"
	
	lazy public var currentLocationButtonBackground: UIColor = {
		if let navigationBar = self.navigationController?.navigationBar,
			barTintColor = navigationBar.barTintColor {
				return barTintColor
		} else { return .whiteColor() }
	}()
	
	public var mapType: MKMapType = .Hybrid {
		didSet {
			if isViewLoaded() {
				mapView.mapType = mapType
			}
		}
	}
	
	public var location: Location? {
		didSet {
			if isViewLoaded() {
				searchBar.text = flatMap(location, { $0.title }) ?? " "
				updateAnnotation()
			}
		}
	}
	
	static let SearchTermKey = "SearchTermKey"
	
	let historyManager = SearchHistoryManager()
	let locationManager = CLLocationManager()
	let geocoder = CLGeocoder()
	var localSearch: MKLocalSearch?
	var searchTimer: NSTimer?
	
	var currentLocationListeners: [CurrentLocationListener] = []
	
	var mapView: MKMapView!
	var locationButton: UIButton?
	
	lazy var results: LocationSearchResultsViewController = {
		let results = LocationSearchResultsViewController()
		results.onSelectLocation = { [weak self] in self?.selectedLocation($0) }
		return results
	}()
	
	lazy var searchController: UISearchController = {
		let search = UISearchController(searchResultsController: self.results)
		search.searchResultsUpdater = self
		search.hidesNavigationBarDuringPresentation = false
		return search
	}()
	
	lazy var searchBar: UISearchBar = {
		let searchBar = self.searchController.searchBar
		searchBar.searchBarStyle = .Minimal
		searchBar.placeholder = self.searchBarPlaceholder
		return searchBar
	}()
	
	deinit {
		searchTimer?.invalidate()
		localSearch?.cancel()
		geocoder.cancelGeocode()
	}
	
	public override func loadView() {
		mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
		mapView.mapType = mapType
		view = mapView
		
		if showCurrentLocationButton {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
			button.backgroundColor = currentLocationButtonBackground
			button.layer.masksToBounds = true
			button.layer.cornerRadius = 16
			let bundle = NSBundle(forClass: LocationPickerViewController.self)
			button.setImage(UIImage(named: "geolocation", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
			button.addTarget(self, action: "currentLocationPressed", forControlEvents: .TouchUpInside)
			view.addSubview(button)
			locationButton = button
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		locationManager.delegate = self
		mapView.delegate = self
		searchBar.delegate = self
		
		// gesture recognizer for adding by tap
		mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "addLocation:"))
		
		// search
		navigationItem.titleView = searchBar
		definesPresentationContext = true
		
		if location == nil && showCurrentLocationInitially {
			showCurrentLocation(animated: false)
		// in else clause because getCurrentLocation() called inside showCurrentLocation()
		} else if useCurrentLocationAsHint {
			getCurrentLocation()
		}
		
		if let location = location {
			// present initial location if any
			self.location = location
			showCoordinates(location.coordinate, animated: false)
		}
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		if let button = locationButton {
			button.frame.origin = CGPoint(
				x: view.frame.width - button.frame.width - 16,
				y: view.frame.height - button.frame.height - 20
			)
		}
	}
	
	func getCurrentLocation() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
	
	func currentLocationPressed() {
		showCurrentLocation()
	}
	
	func showCurrentLocation(animated: Bool = true) {
		mapView.showsUserLocation = true
		let listener = CurrentLocationListener(context: nil, once: true) { [weak self] location in
			self?.showCoordinates(location.coordinate, animated: animated)
		}
		currentLocationListeners.append(listener)
		getCurrentLocation()
	}
	
	func updateAnnotation() {
		if let annotations = mapView.annotations {
			mapView.removeAnnotations(annotations)
		}
		if let location = location {
			mapView.addAnnotation(location)
			mapView.selectAnnotation(location, animated: true)
		}
	}
	
	func showCoordinates(coordinate: CLLocationCoordinate2D, animated: Bool = true) {
		let region = MKCoordinateRegionMakeWithDistance(coordinate, resultRegionDistance, resultRegionDistance)
		mapView.setRegion(region, animated: animated)
	}
}

extension LocationPickerViewController: CLLocationManagerDelegate {
	public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
		if let locations = locations as? [CLLocation], location = locations.first {
			for listener in currentLocationListeners {
				listener.action(location)
			}
			currentLocationListeners = currentLocationListeners.filter { !$0.once }
			manager.stopUpdatingLocation()
		}
	}
}

// MARK: Searching

extension LocationPickerViewController: UISearchResultsUpdating {
	public func updateSearchResultsForSearchController(searchController: UISearchController) {
		searchTimer?.invalidate()
		
		let whitespaces = NSCharacterSet.whitespaceCharacterSet()
		let searchTerm = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaces)
		
		if searchTerm.isEmpty {
			results.locations = historyManager.history()
			results.isShowingHistory = true
			results.tableView.reloadData()
		} else {
			// clear old results
			showItemsForSearchResult(nil)
			
			searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.2,
				target: self, selector: "searchFromTimer:",
				userInfo: [LocationPickerViewController.SearchTermKey: searchTerm],
				repeats: false)
		}
	}
	
	func searchFromTimer(timer: NSTimer) {
		if let userInfo = timer.userInfo as? [String: AnyObject],
			let term = userInfo[LocationPickerViewController.SearchTermKey] as? String {
				let request = MKLocalSearchRequest()
				request.naturalLanguageQuery = term
				
				if let location = locationManager.location where useCurrentLocationAsHint {
					request.region = MKCoordinateRegion(center: location.coordinate,
						span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2))
				}
				
				localSearch?.cancel()
				localSearch = MKLocalSearch(request: request)
				localSearch!.startWithCompletionHandler { response, error in
					self.showItemsForSearchResult(response)
				}
		}
	}
	
	func showItemsForSearchResult(searchResult: MKLocalSearchResponse?) {
		let locations: [Location]
		if let response = searchResult, let mapItems = response.mapItems as? [MKMapItem] {
			locations = map(mapItems) { Location(name: $0.name, placemark: $0.placemark) }
		} else { locations = [] }
		results.locations = locations
		results.isShowingHistory = false
		results.tableView.reloadData()
	}
	
	func selectedLocation(location: Location) {
		// dismiss search results
		dismissViewControllerAnimated(true) {
			// set location, this also adds annotation
			self.location = location
			self.showCoordinates(location.coordinate)
			
			self.historyManager.addToHistory(location)
		}
	}
}

// MARK: Selecting location with gesture

extension LocationPickerViewController {
	func addLocation(gestureRecognizer: UIGestureRecognizer) {
		if gestureRecognizer.state == .Began {
			let point = gestureRecognizer.locationInView(mapView)
			let coordinates = mapView.convertPoint(point, toCoordinateFromView: mapView)
			let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
			
			// clean location, cleans out old annotation too
			self.location = nil
			
			// add point annotation to map
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinates
			mapView.addAnnotation(annotation)
			
			geocoder.cancelGeocode()
			geocoder.reverseGeocodeLocation(location) { response, error in
				if let error = error {
					// show error and remove annotation
					let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { _ in }))
					self.presentViewController(alert, animated: true) {
						self.mapView.removeAnnotation(annotation)
					}
				} else if let placemark = (response as? [CLPlacemark])?.first {
					// get POI name from placemark if any
					let name = (placemark.areasOfInterest as? [String])?.first
					
					// pass user selected location too
					self.location = Location(name: name, location: location, placemark: placemark)
				}
			}
		}
	}
}

// MARK: MKMapViewDelegate

extension LocationPickerViewController: MKMapViewDelegate {
	public func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		if annotation is MKUserLocation {
			return nil
		}
		let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
		pin.pinColor = .Green
		// drop only on long press gesture
		let fromLongPress = annotation is MKPointAnnotation
		pin.animatesDrop = fromLongPress
		pin.rightCalloutAccessoryView = selectLocationButton()
		pin.canShowCallout = !fromLongPress
		return pin
	}
	
	func selectLocationButton() -> UIButton {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
		button.setTitle("Select", forState: .Normal)
		button.setTitleColor(view.tintColor, forState: .Normal)
		return button
	}
	
	public func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
		completion?(location)
		if let navigation = navigationController where navigation.viewControllers.count > 1 {
			navigation.popViewControllerAnimated(true)
		} else {
			presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	public func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
		if let annotations = mapView.annotations {
			let pins = annotations.filter({ $0 is MKPinAnnotationView })
			assert(pins.count <= 1, "Only 1 pin annotation should be on map at a time")
		}
	}
}

// MARK: UISearchBarDelegate

extension LocationPickerViewController: UISearchBarDelegate {
	public func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
		// dirty hack to show history when there is no text in search bar
		// to be replaced later (hopefully)
		if searchBar.text.isEmpty {
			searchBar.text = " "
		}
	}
	
	public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		// remove location if user presses clear or removes text
		if searchText.isEmpty {
			location = nil
		}
	}
}