//
//  Location.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 7/29/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import Foundation

import CoreLocation
import MapKit
import AddressBookUI

// class because protocol
public class Location: NSObject {
	public let name: String
	public let address: String
	public let coordinates: CLLocation
	
	init(name: String, address: String, coordinates: CLLocation) {
		self.name = name
		self.address = address
		self.coordinates = coordinates
	}
	
	convenience init(name: String?, placemark: CLPlacemark) {
		let address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, true)
		self.init(name: name ?? address, address: address, coordinates: placemark.location)
	}
}

extension Location: MKAnnotation {
    @objc public var coordinate: CLLocationCoordinate2D {
		return coordinates.coordinate
	}
	
    public var title: String {
		return name
	}
}