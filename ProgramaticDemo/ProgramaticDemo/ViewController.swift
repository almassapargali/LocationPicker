//
//  ViewController.swift
//  ProgramaticDemo
//
//  Created by Mussa Charles on 2021/05/19.
//

import UIKit
import LocationPicker
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    var selectedLocationCoordinates:CLLocationCoordinate2D?
    var selectedLocationName:String?
    
    
    // MARK: - Views
    private let infoLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "No location selected"
        if #available(iOS 13, *) {
            label.textColor = UIColor.label
        } else {
            label.textColor = UIColor.black
        }

//        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let showPickerButton:UIButton = {
       let button = UIButton()
        button.setTitle("push to locationPicker", for: .normal)
        
        if #available(iOS 13, *) {
            button.setTitleColor(UIColor.systemBlue, for: .normal)
            button.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            button.setTitleColor(UIColor.blue, for: .normal)
            button.layer.borderColor = UIColor.blue.cgColor
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1
     
        button.titleEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    private let presentPickerButton:UIButton = {
       let button = UIButton()
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitle("present locationPicker", for: .normal)
        button.layer.borderWidth = 1
        button.titleEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        if #available(iOS 13, *) {
            button.setTitleColor(UIColor.systemBlue, for: .normal)
            button.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            button.setTitleColor(UIColor.blue, for: .normal)
            button.layer.borderColor = UIColor.blue.cgColor
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var contentsVStack:UIStackView = {
        
        let vStack = UIStackView(arrangedSubviews: [
            infoLabel,
            showPickerButton,
            presentPickerButton
        ])
        vStack.alignment = .fill
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.spacing = 40
        return vStack
    }()
    
    lazy var locationPicker:LocationPickerViewController =  {
        let locationPicker = LocationPickerViewController()
    
        // Init with the previous or auto detected location
        if let selectedCoordinates = self.selectedLocationCoordinates,
           let selectedLocationName = self.selectedLocationName {
            let placemark = MKPlacemark(coordinate: selectedCoordinates, addressDictionary: nil)
            let location = Location(name: selectedLocationName, location: nil, placemark: placemark)
            locationPicker.location = location
        }
        
        // Custominizations
        locationPicker.dismissImmediatelyAfterTableViewSelection = true
        locationPicker.showCancelButtonOnNavBar = true
        locationPicker.showCurrentLocationButton = true
        locationPicker.currentLocationButtonBackground = UIColor.white.withAlphaComponent(0.5)
        locationPicker.showCurrentLocationInitially = true
        locationPicker.mapType = .standard
        locationPicker.useCurrentLocationAsHint = true
        locationPicker.searchBarPlaceholder = "Location name or address"
        locationPicker.searchHistoryLabel = "Search History"
        locationPicker.resultRegionDistance = 500
        locationPicker.mapType = .standard
        
        // Get info after user finish selecting location
        locationPicker.completion = { [weak self] location in
            guard let self = self else {return}
         
            self.infoLabel.text = "locality: \(location?.placemark.locality ?? "nil")\n\ntittle: \(location?.title ?? "nil"), \n\nCoordinate: \(location?.coordinate), \n\nsubLocality \(location?.placemark.subLocality))"

            DispatchQueue.main.async {
                if let selectedLocationCoordiate = location?.coordinate {
                    self.selectedLocationCoordinates = selectedLocationCoordiate

                }

                if let selectedLocationName = location?.title/*location?.placemark.locality*/ {
                    self.selectedLocationName = selectedLocationName
                }
            }


        }
        
        
        return locationPicker
    }()
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Programtic sample"
        autoLayout()
        addGestureRecognizers()
        
        if #available(iOS 13, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }

    }
    
    private func autoLayout(){
        contentsVStack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(contentsVStack)
        
        NSLayoutConstraint.activate([
            contentsVStack.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            contentsVStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            contentsVStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20),
            
            
        ])
        
    }
    
    // MARK: - Helpers
    
    private func addGestureRecognizers(){
        showPickerButton.addTarget(self, action: #selector(didTapShowPicker), for: .touchUpInside)
        presentPickerButton.addTarget(self, action: #selector(didTapPresentPicker), for: .touchUpInside)
        
    }
    
    
    @objc private func didTapShowPicker() {
        self.navigationController?.pushViewController(locationPicker, animated: true)
        
    }
    
    
    @objc private func didTapPresentPicker() {
        self.present(UINavigationController(rootViewController: locationPicker), animated: true, completion: nil)
    }


}



