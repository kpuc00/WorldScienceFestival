//
//  EventCell.swift
//  WorldScienceFestival
//
//  Created by Kristiyan Strahilov on 9.01.23.
//

import UIKit

class EventCell: UICollectionViewCell {
    static let identifier = "eventItem"
    
    @IBOutlet weak var lbAvailability: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbEventTitle: UILabel!
    @IBOutlet weak var lbAgeGroup: UILabel!
    @IBOutlet weak var lbStartTime: UILabel!
    @IBOutlet weak var lbDuration: UILabel!
    @IBOutlet weak var lbPeopleLeft: UILabel!
    @IBOutlet weak var btnBook: UIButton!
}
