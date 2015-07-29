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
}

extension Location: MKAnnotation {
    @objc public var coordinate: CLLocationCoordinate2D {
		return coordinates.coordinate
	}
	
    public var title: String {
		return name
	}
}