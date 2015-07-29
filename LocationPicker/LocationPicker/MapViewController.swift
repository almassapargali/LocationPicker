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
			if let location = location {
				searchBar.text = location.name
			} else {
				searchBar.text = ""
			}
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
	
	override public func loadView() {
		mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
		view = mapView
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		
		// gesture recognizer for adding by tap
		mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "addLocation:"))
		
		// search
		navigationItem.titleView = searchBar
		definesPresentationContext = true
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
		// remove old locations
		cleanAnnotations()
		
		self.location = location
		
		// dismiss search results
		dismissViewControllerAnimated(true) {
			// change review to center result location
			let region = MKCoordinateRegionMakeWithDistance(location.coordinate,
				self.resultRegionDistance, self.resultRegionDistance)
			self.mapView.setRegion(region, animated: true)
			
			// add annotation
			self.mapView.addAnnotation(location)
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
			
			// remove current location
			cleanAnnotations()
			
			// add annotation to map
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinates
			mapView.addAnnotation(annotation)
			
			geocoder.cancelGeocode()
			geocoder.reverseGeocodeLocation(location) { response, error in
				let placemark = (response as? [CLPlacemark])?.first
				if let placemark = placemark {
					// get POI name from placemark if any
					let name = (placemark.areasOfInterest as? [String])?.first
					self.location = Location(name: name, placemark: placemark)
					
					// set annotatio title
					annotation.title = self.location!.title
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
}