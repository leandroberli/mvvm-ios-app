//
//  APODTableViewModel.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 23/12/2021.
//

import Foundation
import UIKit

protocol APODTableViewDelegate {
    func filterAction()
}

class APODTableViewModel {
    
    typealias ButtonClosure = (() -> (Void))?
    
    var touchFilterAction: (() -> (Void))?
    var APODModels: [APOD] = []
    
    var getHeaderView: UIView {
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
            imageView.pin(.trailing, to: view, constant: -10)
            imageView.pin(.centerY, to: view)
            return view
        }
    }
    
    var filterButton: UIButton {
        get {
            let selectDateButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
            selectDateButton.setTitle("Choose date", for: .normal)
            selectDateButton.setTitleColor(.black, for: .normal)
            return selectDateButton
        }
    }
    
    var getFilterNavItem: UIBarButtonItem {
        get {
            let button = filterButton
            button.addTarget(self, action: #selector(filterButtonAction), for: .touchUpInside)
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
            view.addSubview(button)
            let navItem = UIBarButtonItem(customView: view)
            return navItem
        }
    }
    
    @objc func filterButtonAction() {
        guard let action = self.touchFilterAction else {
            print("ERROR: ", #function )
            return
        }
        action()
    }
    
}
