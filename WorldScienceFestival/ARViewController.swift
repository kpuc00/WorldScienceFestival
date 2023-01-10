//
//  ARViewController.swift
//  WorldScienceFestival
//
//  Created by Kristiyan Strahilov on 10.01.23.
//

import UIKit
import RealityKit

class ARViewController: UIViewController {
    @IBOutlet var arView: ARView!
    @IBOutlet weak var lbModel: UILabel!
    var model: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        lbModel.text = "Showing a model of a " + model
        // Load a Reality File
        let rocketAnchor = try! Experience.loadRocket()
        let bearAnchor = try! Experience.loadBear()
        let dinosaurAnchor = try! Experience.loadDinosaur()

        // Add the model anchor to the scene
        switch model {
        case "Rocket":
            arView.scene.anchors.append(rocketAnchor)
        case "Bear":
            arView.scene.anchors.append(bearAnchor)
        case "Dinosaur":
            arView.scene.anchors.append(dinosaurAnchor)
        default:
            print("Unknown model")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        arView.session.pause()
    }
}
