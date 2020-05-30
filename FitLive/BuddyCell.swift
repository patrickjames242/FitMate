//
//  BuddyCell.swift
//  FitLive
//
//  Created by Akeil S on 5/30/20.
//  Copyright © 2020 Patrick Hanna. All rights reserved.
//

import UIKit

class BuddyCell: UITableViewCell {
    @IBOutlet weak var buddySlot: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var callButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
    }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
     
    }
    
}
