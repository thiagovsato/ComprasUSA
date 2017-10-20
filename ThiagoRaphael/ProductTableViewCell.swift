//
//  ProductTableViewCell.swift
//  ThiagoRaphael
//
//  Created by Usuario on 10/9/17.
//  Copyright © 2017 ThiagoRaphael. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbProductName: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
