//
//  ClosingTimeCell.swift
//  rub a dub
//
//  Created by Jonah Ramchandani on 10/04/2024.
//

import UIKit

class ClosingTimesCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
