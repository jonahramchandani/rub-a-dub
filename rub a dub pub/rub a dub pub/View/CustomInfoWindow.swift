//
//  CustomInfoWindow.swift
//  rub a dub pub
//
//  Created by Jonah Ramchandani on 08/02/2024.
//

import UIKit

protocol InfoWindowDelegate: MapViewController {
    func windowTapped()
}

class CustomInfoWindow: UIView {
    
    @IBOutlet weak var pubImage: UIImageView!
    @IBOutlet weak var didTapWindow: UIButton!
    @IBOutlet weak var pubName: UILabel!
    @IBOutlet weak var pubDistance: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var eventToday: UILabel!
    
    weak var delegate: InfoWindowDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backView.layer.cornerRadius = 8.0
        backView.layer.masksToBounds = true
        
    }
    
    @IBAction func windowTapped(_ sender: Any) {
        delegate?.windowTapped()
    }
    

}
