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
    var touchFilterAction: (() -> (Void))?
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
    
}
