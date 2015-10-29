//
//  CustomTableViewCell.swift
//  RoomScheduler
//
//  Created by Mike Henry on 10/29/15.
//  Copyright © 2015 Mike Henry. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var dayImage         :UIImageView!
    @IBOutlet weak var eventTitleLabel  :UILabel!
    @IBOutlet weak var eventStartLabel  :UILabel!
    @IBOutlet weak var eventEndLabel    :UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
