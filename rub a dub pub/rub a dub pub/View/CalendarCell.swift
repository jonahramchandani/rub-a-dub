//
//  CalendarCell.swift
//  rub a dub
//
//  Created by Jonah Ramchandani on 11/04/2024.
//

import UIKit

class CalendarCell: UITableViewCell {

    @IBOutlet weak var whatsOnLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
