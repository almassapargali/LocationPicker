//
//  ViewController.swift
//  ProgramaticDemo
//
//  Created by Mussa Charles on 2021/05/19.
//

import UIKit
import LocationPicker

class ViewController: UIViewController {
    
    
    private let infoLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "No location selected"
//        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let showPickerButton:UIButton = {
       let button = UIButton()
        button.setTitle("push to locationPicker", for: .normal)
//        button.setTitleColor(UIColor.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let presentPickerButton:UIButton = {
       let button = UIButton()
//        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitle("present locationPicker", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
 
    
    private lazy var contentsVStack:UIStackView = {
        
        let topSpacer = UIView()
        let bottomSpacer = UIView()
        
        let vStack = UIStackView(arrangedSubviews: [
            topSpacer,
            infoLabel,
            showPickerButton,
            presentPickerButton,
            bottomSpacer
        ])
        vStack.alignment = .center
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.spacing = 40
        return vStack
    }()
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Programtic sample"
//        view.backgroundColor = UIColor.white
        autoLayout()
        addGestureRecognizers()
    }
    
    private func autoLayout(){
        contentsVStack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(contentsVStack)
        
        NSLayoutConstraint.activate([
            contentsVStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            contentsVStack.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            
        ])
        
    }
    
    // MARK: - Helpers
    
    private func addGestureRecognizers(){
        showPickerButton.addTarget(self, action: #selector(didTapShowPicker), for: .touchUpInside)
        presentPickerButton.addTarget(self, action: #selector(didTapPresentPicker), for: .touchUpInside)
        
    }
    
    
    var locationPicker:LocationPickerViewController {
        let picker = LocationPickerViewController()
        picker.mapType = .standard
        return picker
    }
    
    
    @objc private func didTapShowPicker() {
        self.navigationController?.pushViewController(locationPicker, animated: true)
        
    }
    
    
    @objc private func didTapPresentPicker() {
        self.present(UINavigationController(rootViewController: locationPicker), animated: true, completion: nil)
    }


}



