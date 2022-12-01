//
//  ProfileViewController.swift
//  WorldScienceFestival
//
//  Created by Kristiyan Strahilov on 1.12.22.
//

import UIKit
import FirebaseAuthUI
import FirebaseEmailAuthUI

class ProfileViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var notLoggedInStack: UIStackView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.notLoggedInStack.alpha = 0.0
        self.logoutButton.alpha = 0.0
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.showUserInfo(user:user)
                self.logoutButton.alpha = 1.0
                self.notLoggedInStack.alpha = 0.0
            } else {
                self.notLoggedInStack.alpha = 1.0
                self.showAuthUI()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
