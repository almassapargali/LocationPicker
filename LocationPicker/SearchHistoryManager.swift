//
//  SearchHistoryManager.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 9/6/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import UIKit
import MapKit

struct SearchHistoryManager {
	private let HistoryKey = "RecentLocationsKey"
	
	private var defaults: NSUserDefaults {
		return NSUserDefaults.standardUserDefaults()
	}
	
	func history() -> [Location] {
		let history: [NSDictionary] = defaults.objectForKey(HistoryKey) as? [NSDictionary] ?? []
		return history.map(Location.fromDefaultsDic).filter({ $0 != nil }).map({ $0! })
	}
	
	func addToHistory(location: Location) {
		var history: [NSDictionary] = defaults.objectForKey(HistoryKey) as? [NSDictionary] ?? []
		let historyNames = history.map { $0[LocationDicKeys.name] as? String }
			.filter({ $0 != nil }).map({ $0! })
		let shouldInclude = flatMap(location.name) { find(historyNames, $0) == nil } ?? true
		if shouldInclude {
			history.append(location.toDefaultsDic())
			defaults.setObject(history, forKey: HistoryKey)
		}
	}
}

struct LocationDicKeys {
	static let name = "Name"
	static let locationCoordinates = "LocationCoordinates"
	static let placemarkCoordinates = "PlacemarkCoordinates"
	static let placemarkAddressDic = "PlacemarkAddressDic"
}

struct CoordinateDicKeys {
	static let latitude = "Latitude"
	static let longitude = "Longitude"
}

extension CLLocationCoordinate2D {
	func toDefaultsDic() -> NSDictionary {
		return [
			CoordinateDicKeys.latitude: latitude,
			CoordinateDicKeys.longitude: longitude
		]
	}
	
	static func fromDefaultsDic(dic: NSDictionary) -> CLLocationCoordinate2D? {
		if let latitude = dic[CoordinateDicKeys.latitude] as? NSNumber,
			longitude = dic[CoordinateDicKeys.longitude] as? NSNumber {
				return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
		} else {
			return nil
		}
	}
}

extension Location {
	func toDefaultsDic() -> NSDictionary {
		var dic: [String: AnyObject] = [
			LocationDicKeys.locationCoordinates: location.coordinate.toDefaultsDic(),
			LocationDicKeys.placemarkCoordinates: placemark.location.coordinate.toDefaultsDic(),
			LocationDicKeys.placemarkAddressDic: placemark.addressDictionary
		]
		if let name = name { dic[LocationDicKeys.name] = name }
		return dic
	}
	
	class func fromDefaultsDic(dic: NSDictionary) -> Location? {
		if let placemarkCoordinatesDic = dic[LocationDicKeys.placemarkCoordinates] as? NSDictionary,
			placemarkCoordinates = CLLocationCoordinate2D.fromDefaultsDic(placemarkCoordinatesDic),
			placemarkAddressDic = dic[LocationDicKeys.placemarkAddressDic] as? [NSObject: AnyObject] {
				let location: CLLocation?
				if let locationCoordinatesDic = dic[LocationDicKeys.locationCoordinates] as? NSDictionary,
					coordinate = CLLocationCoordinate2D.fromDefaultsDic(locationCoordinatesDic) {
						location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
				} else {
					location = nil
				}
				return Location(name: dic[LocationDicKeys.name] as? String,
					location: location,
					placemark: MKPlacemark(coordinate: placemarkCoordinates,
						addressDictionary: placemarkAddressDic))
		} else {
			return nil
		}
	}
}