//
//  LocationSearchResultsViewController.swift
//  LocationPicker
//
//  Created by Almas Sapargali on 7/29/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchResultsViewController: UITableViewController {
	var locations: [Location] = []
	var onSelectLocation: (Location -> ())?
	var isShowingHistory = false
	var searchHistoryLabel: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		extendedLayoutIncludesOpaqueBars = true
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return isShowingHistory ? searchHistoryLabel : nil
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return locations.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell")
			?? UITableViewCell(style: .Subtitle, reuseIdentifier: "LocationCell")
		
		let location = locations[indexPath.row]
		cell.textLabel?.text = location.name
		cell.detailTextLabel?.text = location.address
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		onSelectLocation?(locations[indexPath.row])
	}
}
