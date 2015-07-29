//
//  MapViewController.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 7/29/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

public class MapViewController: UIViewController {
	public var completion: (Location? -> ())?
	lazy var resultRegionDistance: CLLocationDistance = 600
	
	public var location: Location? {
		didSet {
			searchBar.text = flatMap(location, { $0.title }) ?? ""
			updateAnnotation()
		}
	}
	
	static let SearchTermKey = "SearchTermKey"
	
	let geocoder = CLGeocoder()
	var localSearch: MKLocalSearch?
	var searchTimer: NSTimer?
	
	var mapView: MKMapView!
	
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
		searchBar.placeholder = "Search places"
		return searchBar
	}()
	
	deinit {
		searchTimer?.invalidate()
		localSearch?.cancel()
		geocoder.cancelGeocode()
	}
	
	public override func loadView() {
		mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
		view = mapView
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		searchBar.delegate = self
		
		// gesture recognizer for adding by tap
		mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "addLocation:"))
		
		// search
		navigationItem.titleView = searchBar
		definesPresentationContext = true
	}
	
	public override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		if (isMovingFromParentViewController() || isBeingDismissed()) {
			completion?(location)
		}
	}
	
	func updateAnnotation() {
		if let location = location {
			// whether it's just update from reverse geocoding or new annotation
			var needsUpdate = true
			
			if let annotations = mapView.annotations as? [MKAnnotation],
				let pointAnnotation = annotations.first as? MKPointAnnotation {
					// if we're updating annotation after getting reverse geocoding results
					if pointAnnotation.coordinate.latitude == location.coordinate.latitude
						&& pointAnnotation.coordinate.longitude == location.coordinate.longitude {
							pointAnnotation.title = location.title
							needsUpdate = false
					}
			}
			
			if needsUpdate {
				cleanAnnotations()
				mapView.addAnnotation(location)
			}
		} else {
			cleanAnnotations()
		}
	}
	
	func cleanAnnotations() {
		if let annotations = mapView.annotations {
			mapView.removeAnnotations(annotations)
		}
	}
}

// MARK: Searching

extension MapViewController: UISearchResultsUpdating {
	public func updateSearchResultsForSearchController(searchController: UISearchController) {
		searchTimer?.invalidate()
		
		// clear old results
		showItemsForSearchResult(nil)
		
		searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.2,
			target: self, selector: "searchFromTimer:",
			userInfo: [MapViewController.SearchTermKey: searchController.searchBar.text],
			repeats: false)
	}
	
	func searchFromTimer(timer: NSTimer) {
		if let userInfo = timer.userInfo as? [String: AnyObject],
			let term = userInfo[MapViewController.SearchTermKey] as? String {
				let request = MKLocalSearchRequest()
				request.naturalLanguageQuery = term
				
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
		self.results.locations = locations
		self.results.tableView.reloadData()
	}
	
	func selectedLocation(location: Location) {
		// dismiss search results
		dismissViewControllerAnimated(true) {
			
			// change review to center result location
			let region = MKCoordinateRegionMakeWithDistance(location.coordinate,
				self.resultRegionDistance, self.resultRegionDistance)
			self.mapView.setRegion(region, animated: true)
			
			// set location, this also adds annotation
			self.location = location
		}
	}
}

// MARK: Selecting location with gesture

extension MapViewController {
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

extension MapViewController: MKMapViewDelegate {
	public func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
		pin.pinColor = .Green
		pin.animatesDrop = true
		pin.canShowCallout = true
		return pin
	}
	
	public func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
		if let annotations = mapView.annotations {
			assert(annotations.count == 1, "Only one annotation should be on map at a time")
		}
	}
}

// MARK: UISearchBarDelegate

extension MapViewController: UISearchBarDelegate {
	public func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		// remove location if user presses clear or removes text
		if searchText.isEmpty {
			location = nil
		}
	}
}