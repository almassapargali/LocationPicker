//
//  ViewController.swift
//  LocationPickerDemo
//
//  Created by Almas Sapargali on 7/29/15.
//  Copyright (c) 2015 almassapargali. All rights reserved.
//

import UIKit
import LocationPicker

class ViewController: UIViewController {
	@IBOutlet weak var locationNameLabel: UILabel!
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "LocationPicker" {
			let locationPicker = segue.destinationViewController as! LocationPickerViewController
			locationPicker.completion = { [weak self] location in
				self?.locationNameLabel.text = flatMap(location, { $0.title }) ?? "No location selected"
			}
		}
	}
}

