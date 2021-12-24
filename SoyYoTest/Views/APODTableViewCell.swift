//
//  APODTableViewCell.swift
//  SoyYoTest
//
//  Created by Leandro Berli on 23/12/2021.
//

import UIKit

class APODTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var pictureHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupModel(_ model: APOD?) {
        guard let apodModel = model else {
            return
        }
        subtitleLabel.text = apodModel.getDateString()
        titleLabel.text = apodModel.title
        descriptionLabel.text = apodModel.explanation
        picture.kf.setImage(with: URL(string: apodModel.url))
        
    }
    
}
