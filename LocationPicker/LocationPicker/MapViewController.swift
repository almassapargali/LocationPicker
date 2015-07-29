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
	public var location: Location? {
		didSet {
			if let location = location {
				searchBar.placeholder = location.name
			}
		}
	}
	
	static let SearchTermKey = "SearchTermKey"
	var searchTimer: NSTimer?
	let geocoder = CLGeocoder()
	
	var mapView: MKMapView!
	
	lazy var results: LocationSearchResultsViewController = {
		let results = LocationSearchResultsViewController()
		results.onSelectLocation = { location in
			self.location = location
			self.searchBar.text = nil
			self.dismissViewControllerAnimated(true, completion: nil)
		}
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
	}
	
	override public func loadView() {
		mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
		view = mapView
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		// search
		navigationItem.titleView = searchBar
		definesPresentationContext = true
	}
	
	func searchFromTimer(timer: NSTimer) {
		if let userInfo = timer.userInfo as? [String: String],
			let term = userInfo[MapViewController.SearchTermKey] {
				geocoder.cancelGeocode()
				
				geocoder.geocodeAddressString(term) { result, error in
					if let places = result as? [CLPlacemark] {
						self.results.locations = map(places) { place in
							let name = (place.areasOfInterest as? [String])?.first
							let address = ABCreateStringWithAddressDictionary(place.addressDictionary, true)
							return Location(name: name ?? address, address: address, coordinates: place.location)
						}
						self.results.tableView.reloadData()
					}
				}
		}
	}
	
	public struct Location {
		public let name: String
		public let address: String
		public let coordinates: CLLocation
	}
}

extension MapViewController: UISearchResultsUpdating {
	public func updateSearchResultsForSearchController(searchController: UISearchController) {
		searchTimer?.invalidate()
		searchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5,
			target: self,
			selector: "searchFromTimer:",
			userInfo: [MapViewController.SearchTermKey: searchController.searchBar.text],
			repeats: false)
	}
}
