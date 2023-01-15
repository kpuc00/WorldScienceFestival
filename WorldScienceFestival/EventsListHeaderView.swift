//
//  EventsListHeaderView.swift
//  WorldScienceFestival
//
//  Created by Kristiyan Strahilov on 15.01.23.
//

import UIKit

class EventsListHeaderView: UICollectionReusableView {
    static let identifier = "eventsHeader"
    
    private let title: UILabel = {
        let label = UILabel()
        label.text = "World Science Festival"
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    public func config(){
        addSubview(title)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        title.frame = bounds
    }
}
