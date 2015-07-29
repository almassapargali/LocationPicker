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
import AddressBookUI

public class MapViewController: UIViewController {
	public var completion: (Location? -> ())?
	lazy var resultRegionDistance: CLLocationDistance = 600
	
	public var location: Location? {
		didSet {
			if let location = location {
				searchBar.text = location.name
			}
		}
	}
	
	static let SearchTermKey = "SearchTermKey"
	
	var localSearch: MKLocalSearch?
	var searchTimer: NSTimer?
	
	var mapView: MKMapView!
	
	lazy var results: LocationSearchResultsViewController = {
		let results = LocationSearchResultsViewController()
		results.onSelectLocation = { self.selectedLocation($0) }
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
	}
	
	override public func loadView() {
		mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
		view = mapView
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		
		// search
		navigationItem.titleView = searchBar
		definesPresentationContext = true
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
	
	func showItemsForSearchResult(searchResult :MKLocalSearchResponse?) {
		var locations: [Location] = []
		if let response = searchResult, let mapItems = response.mapItems as? [MKMapItem] {
			locations = map(mapItems) { mapItem in
				let place = mapItem.placemark
				let address = ABCreateStringWithAddressDictionary(place.addressDictionary, true)
				return Location(name: mapItem.name , address: address, coordinates: place.location)
			}
		}
		self.results.locations = locations
		self.results.tableView.reloadData()
	}
	
	func selectedLocation(location: Location) {
		// remove old location
		if let location = self.location {
			mapView.removeAnnotation(location)
		}
		
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