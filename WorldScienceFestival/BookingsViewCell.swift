//
//  BookingsViewCell.swift
//  WorldScienceFestival
//
//  Created by Kristiyan Strahilov on 10.01.23.
//

import UIKit

class BookingsViewCell: UICollectionViewCell {
    static let identifier = "bookingItem"
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbEventTitle: UILabel!
    @IBOutlet weak var lbAgeGroup: UILabel!
    @IBOutlet weak var lbStartTime: UILabel!
    @IBOutlet weak var lbDuration: UILabel!
}
