//
//  APODTableViewModel.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 23/12/2021.
//

import Foundation
import UIKit

class APODTableViewModel {
    var touchFilterAction: (() -> (Void))?
    var touchDoneFilterAction: (() -> Void)?
    var touchSevenDaysFilterAction: (() -> Void)?
    var APODModels: [APOD] = []
    
    var cellReuseId: String {
        get {
            return "APODTableViewCell"
        }
    }
    
    var cellNib: UINib {
        get {
            return UINib(nibName: "APODTableViewCell", bundle: nil)
        }
    }
    
    var datePicker: UIDatePicker {
        get {
            let picker = UIDatePicker()
            picker.preferredDatePickerStyle = .wheels
            picker.datePickerMode = .date
            //today
            picker.maximumDate = Date()
            return picker
        }
    }
    
    var dateToolbar: UIToolbar {
        get {
            let toolbar = UIToolbar()
            toolbar.barStyle = .default
            toolbar.sizeToFit()
            
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(filterDoneButtonAction))
            let doneButton2 = UIBarButtonItem(title: "Last 7 days", style: .plain, target: self, action: #selector(filterSevenDaysButtonAction))
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace , target: nil, action: nil)
            
            toolbar.setItems([space, doneButton2, doneButton ], animated: false)
            toolbar.isUserInteractionEnabled = true
            
            return toolbar
        }
    }
    
    var headerView: UIView {
        get {
            let button = UIButton()
            button.setTitle("Last 7 days", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.gray, for: .highlighted)
            button.addTarget(self, action: #selector(filterButtonAction), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            button.contentHorizontalAlignment = .left
            button.sizeToFit()
            let view = UIView(frame: button.bounds)
            view.addSubview(button)
            button.pin(.leading, .trailing, to: view, constant: 10)
            button.pin(.centerY, to: view)
            
            let arrowDownImage = UIImage(systemName: "chevron.down")
            let imageView = UIImageView(image: arrowDownImage)
            imageView.tintColor = .black
            view.addSubview(imageView)
            view.backgroundColor = .white
            imageView.pin(.trailing, to: view, constant: -10)
            imageView.pin(.centerY, to: view)
            return view
        }
    }
    
    @objc func filterButtonAction() {
        guard let action = self.touchFilterAction else {
            print("ERROR: ", #function )
            return
        }
        action()
    }
    
    @objc func filterDoneButtonAction() {
        guard let action = self.touchDoneFilterAction else {
            print("ERROR: ", #function )
            return
        }
        action()
    }
    
    @objc func filterSevenDaysButtonAction() {
        guard let action = self.touchSevenDaysFilterAction else {
            print("ERROR: ", #function )
            return
        }
        action()
    }
    
}
