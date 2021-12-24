//
//  APODDetailViewController.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 23/12/2021.
//

import UIKit
import Kingfisher

class APODDetailViewController: UIViewController {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    var apod: APOD!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupModel(apod)
    }
    
    public func setupModel(_ model: APOD) {
        titleLabel.text = model.title
        dateLabel.text = model.date
        descLabel.text = model.explanation
        picture.kf.setImage(with: URL(string: model.url))
        if model.copyright != nil {
            copyrightLabel.text = model.copyright
        } else {
            copyrightLabel.isHidden = true
        }
    }
}
