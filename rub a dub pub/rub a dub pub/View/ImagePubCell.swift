//
//  ImagePubCellTableViewCell.swift
//  rub a dub
//
//  Created by Jonah Ramchandani on 20/02/2024.
//

import UIKit

class ImagePubCell: UITableViewCell {
    
    @IBOutlet weak var pubImage: UIImageView!
    @IBOutlet weak var pubName: UILabel!
    @IBOutlet weak var pubDistance: UILabel!
    @IBOutlet weak var pubOpen: UILabel!
    @IBOutlet weak var pubDesc: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
