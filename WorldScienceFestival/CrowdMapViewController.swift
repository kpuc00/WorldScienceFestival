//
//  CrowdMapViewController.swift
//  WorldScienceFestival
//
//  Created by Kristiyan Strahilov on 9.01.23.
//

import UIKit
import FirebaseFirestore

class CrowdMapViewController: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var bioEvent: UILabel!
    @IBOutlet weak var rocketEvent: UILabel!
    @IBOutlet weak var historicEvent: UILabel!
   
    private func colorize(_ label: UILabel,_ people: Int, _ maxPeople: Int) {
        if(people < maxPeople/4){
            label.backgroundColor = .green
        }
        else if (people >= maxPeople/4 && people < maxPeople){
            label.backgroundColor = .yellow
        }
        else {
            label.backgroundColor = .red
        }
    }
    
    private func loadHeatMap() {
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        // Load events from mock data or API
        let db = Firestore.firestore()
        
        db.collection("events").order(by: "startingTime").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let event = document.data()
                    
                    let eventTitle = event["eventTitle"] as! String
                    let people = event["people"] as! Int
                    let maxPeople = event["maxPeople"] as! Int
                    print(eventTitle)
                    
                    switch eventTitle {
                    case "History of dinosaurs":
                        self.colorize(self.historicEvent, people, maxPeople)
                    case "Rocket science":
                        self.colorize(self.rocketEvent, people, maxPeople)
                    case "Bio nature":
                        self.colorize(self.bioEvent, people, maxPeople)
                    default:
                        print("Unknown event")
                    }
                }
            }
            self.spinner.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        loadHeatMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHeatMap()
    }
}
