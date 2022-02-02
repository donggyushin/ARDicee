//
//  ViewModel.swift
//  ARDicee
//
//  Created by 신동규 on 2022/02/01.
//

import Combine
import SceneKit
import ARKit
import UIKit

class ViewModel {
    @Published var alertMessage: String?
    var subscriber: Set<AnyCancellable> = .init()
    
    func viewWillApear(sceneView: ARSCNView) {
        if ARWorldTrackingConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            // Run the view's session
            sceneView.session.run(configuration)
        } else {
            self.alertMessage = "Your device is not available for AR World Tracking Service. Sorry for inconvenience"
        }
    }
    
    func viewWillDisappear(sceneView: ARSCNView) {
        sceneView.session.pause()
    }
    
    func createMoonNode() -> SCNNode {
        let moon = SCNSphere(radius: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpeg")
        moon.materials = [material]
        let node = SCNNode()
        node.position = .init(-1, 1, -1)
        node.geometry = moon
        return node
    }
    
    func createDiceNode() -> SCNNode {
        guard let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn") else { return .init() }
        guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else { return .init() }
        diceNode.position = .init(0, 0, -0.1)
        return diceNode
    }
}
