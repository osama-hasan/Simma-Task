//
//  CartCell.swift
//  Simma Task
//
//  Created by Osama Hasan on 17/10/2023.
//

import UIKit
import Kingfisher

class CartCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setData(model:CartProduct){
        if let url = URL(string: model.imageUrl){
            productImageView.kf.setImage(
                with: url,
                options: [
                    .loadDiskFileSynchronously,
                    .cacheOriginalImage,
                    .transition(.fade(0.25)),
                ],
                progressBlock: { receivedSize, totalSize in
                    // Progress updated
                },
                completionHandler: { result in
                    // Done
                }
            )

        }
        
        priceLabel.text = "Price: \(model.price) $"
        titleLabel.text =  model.title
        quantityLabel.text = "Quantity: \(model.quantity)"

    }
    
}
