//
//  HomeViewController.swift
//  WorldScienceFestival
//
//  Created by Kristiyan Strahilov on 1.12.22.
//

import UIKit
import FirebaseFirestore

class EventsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    var events: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Load events from mock data or API
        let db = Firestore.firestore()
        
        db.collection("events").order(by: "startingTime").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.events.append(data)
                }
                self.collectionView.reloadData()
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as! EventCell
        let event = events[indexPath.item]
        let peopleLeft = (event["maxPeople"] as! Int) - (event["people"] as! Int)
        let startingTime = event["startingTime"] as! Timestamp
        let endingTime = event["endingTime"] as! Timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let durationDouble = DateInterval(start: startingTime.dateValue(), end: endingTime.dateValue()).duration
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.allowedUnits = [.hour, .minute]
        durationFormatter.unitsStyle = .full
        let duration = durationFormatter.string(from: durationDouble) ?? "Unknown"
        
        
        if (peopleLeft < 1) {
            cell.lbAvailability.text = "NOT AVAILABLE"
            cell.btnBook.isEnabled = false
            cell.btnBook.setTitle("Booked out", for: UIControl.State.normal)
        }
        else {
            cell.lbAvailability.text = "AVAILABLE"
        }
        cell.lbDate.text = dateFormatter.string(from: startingTime.dateValue())
        cell.lbEventTitle.text = (event["eventTitle"] as! String)
        cell.lbAgeGroup.text = (event["ageGroup"] as! String)
        cell.lbStartTime.text = timeFormatter.string(from: startingTime.dateValue())
        cell.lbDuration.text = duration
        cell.lbPeopleLeft.text = String(peopleLeft)
        
        //This creates the shadows and modifies theda cards a little bit
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
}
