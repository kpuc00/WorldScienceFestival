//
//  ProfileViewController.swift
//  WorldScienceFestival
//
//  Created by Kristiyan Strahilov on 1.12.22.
//

import UIKit
import FirebaseAuthUI
import FirebaseEmailAuthUI
import FirebaseFirestore

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var bookings: UICollectionView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var notLoggedInStack: UIStackView!
    @IBOutlet weak var loggedInStack: UIStackView!
    let db = Firestore.firestore()
    
    var events: [[String: Any]] = []
//    var bookedEvents : [String] = []
    let images : [String] = ["1","2","3","4","5","6","7","8","9","10"]
    
    private func loadEvents() {
        events = []
//        bookedEvents = []
        spinner.startAnimating()
        
        // Load events from mock data or API
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.db.collection("users").document(user.uid).collection("bookings").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            let bookedTitle = document.data()["eventTitle"] as! String
//                            self.bookedEvents.append()
                            
                            self.db.collection("events").order(by: "startingTime").getDocuments { (querySnapshot, error) in
                                if let error = error {
                                    print("Error getting documents: \(error)")
                                } else {
                                    for document in querySnapshot!.documents {
                                        let event = document.data()
                                        if(event["eventTitle"] as! String == bookedTitle){
                                            self.events.append(event)
                                        }
                                    }
                                    self.bookings.reloadData()
                                }
                            }
                        }
                        self.spinner.stopAnimating()
                    }
                }
            } else {}
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailLabel.text = ""
        self.notLoggedInStack.alpha = 0.0
        self.logoutButton.alpha = 0.0
        self.loggedInStack.alpha = 0.0
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.db.collection("users").document(user.uid).setData([
                    "uid": user.uid
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                self.showUserInfo(user:user)
                self.logoutButton.alpha = 1.0
                self.notLoggedInStack.alpha = 0.0
                self.loggedInStack.alpha = 1.0
                self.loadEvents()
            } else {
                self.notLoggedInStack.alpha = 1.0
                self.loggedInStack.alpha = 0.0
                self.showAuthUI()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bookings.dataSource = self
        bookings.delegate = self
        spinner.hidesWhenStopped = true
    }
    
    func showUserInfo(user: User) {
        print("logged in")
        self.emailLabel.text = user.email
    }
    
    func showAuthUI() {
        print("not logged in")
        // Get default Auth UI object
        let authUI = FUIAuth.defaultAuthUI()
        guard authUI != nil else {
            // Log the error
            return
        }

        // Set ourselves as delegate
        authUI?.delegate = self
        authUI?.providers = [FUIEmailAuth()]

        // Get a reference to the Auth UI view controller
        let authViewController = authUI!.authViewController()

        // Show it
        present(authViewController, animated: true,completion: nil)
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            self.logoutButton.alpha = 0.0
            self.emailLabel.text = ""
            self.notLoggedInStack.alpha = 1.0
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        self.showAuthUI()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookingsViewCell.identifier, for: indexPath) as! BookingsViewCell
        let event = events[indexPath.item]
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
        
        cell.eventImage.image = UIImage(named: images.randomElement()!)
        cell.lbDate.text = dateFormatter.string(from: startingTime.dateValue())
        cell.lbEventTitle.text = (event["eventTitle"] as! String)
        cell.lbAgeGroup.text = (event["ageGroup"] as! String)
        cell.lbStartTime.text = timeFormatter.string(from: startingTime.dateValue())
        cell.lbDuration.text = duration
        
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
        let cell = collectionView.cellForItem(at: indexPath) as! BookingsViewCell
        let event = events[indexPath.item]
        
    }
}

extension ProfileViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        // Check if there was an error
        
        if error != nil {
            // Log the error
            return
        }
        
//        authDataResult?.user.uid
//        performSegue(withIdentifier: "goHome", sender: self)
    }
}
