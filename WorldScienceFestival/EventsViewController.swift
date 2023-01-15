//
//  HomeViewController.swift
//  WorldScienceFestival
//
//  Created by Kristiyan Strahilov on 1.12.22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuthUI

class EventsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var collectionView: UICollectionView!
    
    let db = Firestore.firestore()
    var events: [[String: Any]] = []
    var bookedEvents : [String] = []
    
    let images : [String] = ["1","2","3","4","5","6","7","8","9","10"]

    private func loadEvents() {
        events = []
        bookedEvents = []
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        // Load events from mock data or API
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
            self.spinner.stopAnimating()
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.db.collection("users").document(user.uid).collection("bookings").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            self.bookedEvents.append(document.data()["eventTitle"] as! String)
                        }
                    }
                }
            } else {
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EventsListHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventsListHeaderView.identifier)
        collectionView.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionReusableView.identifier)
        
//        loadEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEvents()
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionHeader){
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EventsListHeaderView.identifier, for: indexPath) as! EventsListHeaderView
            header.config()
            return header
        }
        else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionReusableView.identifier, for: indexPath) as! CollectionReusableView
            return footer
        }
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
        else if (bookedEvents.contains(event["eventTitle"] as! String)){
            cell.lbAvailability.text = "AVAILABLE"
            cell.btnBook.isEnabled = false
            cell.btnBook.setTitle("Booked", for: UIControl.State.normal)
        }
        else {
            cell.lbAvailability.text = "AVAILABLE"
            cell.btnBook.isEnabled = true
            cell.btnBook.setTitle("Book", for: UIControl.State.normal)
        }
        cell.eventImage.image = UIImage(named: images.randomElement()!)
        cell.lbDate.text = dateFormatter.string(from: startingTime.dateValue())
        cell.lbEventTitle.text = (event["eventTitle"] as! String)
        cell.lbAgeGroup.text = (event["ageGroup"] as! String)
        cell.lbStartTime.text = timeFormatter.string(from: startingTime.dateValue())
        cell.lbDuration.text = duration
        cell.lbPeopleLeft.text = String(peopleLeft)
        cell.btnBook.tag = indexPath.item
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! EventCell
        let event = events[indexPath.item]
        
    }
    
    @IBAction func bookPressed(_ sender: UIButton) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let index: Int = sender.tag
                let event = self.events[index]
                let eventTitle = event["eventTitle"] as! String
                
                self.showConfirmation(eventTitle, user)
            } else {
                self.showAlert("Warning", "You need to be logged in to book events!")
            }
        }
    }
    
    func showConfirmation(_ eventTitle: String, _ user: User){
        let alert = UIAlertController(title: "Confirm booking", message: "You are booking a place at the event: \(eventTitle)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
            self.db.collection("users").document(user.uid).collection("bookings").document().setData([
                "eventTitle": eventTitle
            ], merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.showAlert("Error", "Something went wrong. Please try again later!")
                } else {
                    print("Document successfully written!")
                    let query = self.db.collection("events").whereField("eventTitle", isEqualTo: eventTitle)
                        query.getDocuments { (querySnapshot, error) in
                            if let error = error {
                                print("Error getting documents: \(error)")
                            } else {
                                for document in querySnapshot!.documents {
                                    print("Document data: \(document.data())")
                                    let docRef = document.reference
                                    docRef.updateData([ "people": FieldValue.increment(Int64(1)) ]) { err in
                                        if let err = err {
                                            print("Error updating document: \(err)")
                                            self.showAlert("Error", "Something went wrong. Please try again later!")
                                        } else {
                                            print("Document successfully updated!")
                                            self.loadEvents()
                                            self.showAlert("Booking", "You successfully booked \(eventTitle)!")
                                        }
                                    }
                                }
                            }
                        }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    func showAlert(_ title: String, _ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alert, animated: true)
    }
    
}
