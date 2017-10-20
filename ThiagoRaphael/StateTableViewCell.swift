//
//  StateTableViewCell.swift
//  ThiagoRaphael
//
//  Created by Usuario on 10/12/17.
//  Copyright © 2017 ThiagoRaphael. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbStateName: UILabel!
    @IBOutlet weak var lbStateTax: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
