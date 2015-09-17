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
		let history = defaults.objectForKey(HistoryKey) as? [NSDictionary] ?? []
		return history.flatMap(Location.fromDefaultsDic)
	}
	
	func addToHistory(location: Location) {
		guard let dic = location.toDefaultsDic() else { return }
		
		var history  = defaults.objectForKey(HistoryKey) as? [NSDictionary] ?? []
		let historyNames = history.flatMap { $0[LocationDicKeys.name] as? String }
		let shouldInclude = location.name.flatMap { historyNames.indexOf($0) == nil } ?? true
		if shouldInclude {
			history.append(dic)
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
		return [CoordinateDicKeys.latitude: latitude, CoordinateDicKeys.longitude: longitude]
	}
	
	static func fromDefaultsDic(dic: NSDictionary) -> CLLocationCoordinate2D? {
		guard let latitude = dic[CoordinateDicKeys.latitude] as? NSNumber,
			longitude = dic[CoordinateDicKeys.longitude] as? NSNumber else { return nil }
		return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
	}
}

extension Location {
	func toDefaultsDic() -> NSDictionary? {
		guard let addressDic = placemark.addressDictionary,
			placemarkCoordinatesDic = placemark.location?.coordinate.toDefaultsDic()
			else { return nil }
		
		var dic: [String: AnyObject] = [
			LocationDicKeys.locationCoordinates: location.coordinate.toDefaultsDic(),
			LocationDicKeys.placemarkAddressDic: addressDic,
			LocationDicKeys.placemarkCoordinates: placemarkCoordinatesDic
		]
		if let name = name { dic[LocationDicKeys.name] = name }
		return dic
	}
	
	class func fromDefaultsDic(dic: NSDictionary) -> Location? {
		guard let placemarkCoordinatesDic = dic[LocationDicKeys.placemarkCoordinates] as? NSDictionary,
			placemarkCoordinates = CLLocationCoordinate2D.fromDefaultsDic(placemarkCoordinatesDic),
			placemarkAddressDic = dic[LocationDicKeys.placemarkAddressDic] as? [String: AnyObject]
			else { return nil }
		
		let coordinatesDic = dic[LocationDicKeys.locationCoordinates] as? NSDictionary
		let coordinate = coordinatesDic.flatMap(CLLocationCoordinate2D.fromDefaultsDic)
		let location = coordinate.flatMap { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
		
		return Location(name: dic[LocationDicKeys.name] as? String,
			location: location,
			placemark: MKPlacemark(coordinate: placemarkCoordinates, addressDictionary: placemarkAddressDic))
	}
}