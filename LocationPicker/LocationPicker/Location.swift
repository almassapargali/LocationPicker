//
//  Location.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 7/29/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import Foundation

import CoreLocation
import AddressBookUI

// class because protocol
public class Location: NSObject {
	public let name: String?
	public let placemark: CLPlacemark
	
	var address: String {
		return ABCreateStringWithAddressDictionary(placemark.addressDictionary, true)
	}
	
	init(name: String?, placemark: CLPlacemark) {
		self.name = name
		self.placemark = placemark
	}
}

import MapKit

extension Location: MKAnnotation {
    @objc public var coordinate: CLLocationCoordinate2D {
		return placemark.location.coordinate
	}
	
    public var title: String {
		return name ?? address
	}
}