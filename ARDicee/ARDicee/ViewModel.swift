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
    @Published var moonNode: SCNNode?
    @Published var diceNode: SCNNode?
    @Published var planeNode: SCNNode?
    
    var subscriber: Set<AnyCancellable> = .init()
    
    func viewDidLoad() {
        self.moonNode = createMoonNode()
        self.diceNode = createDiceNode()
    }
    
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
    
    func planeAnchorDetected(planeAnchor: ARPlaneAnchor) {
        let plane: SCNPlane = .init(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode: SCNNode = .init()
        planeNode.position = .init(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        self.planeNode = planeNode
    }
    
    private func createMoonNode() -> SCNNode {
        let moon = SCNSphere(radius: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpeg")
        moon.materials = [material]
        let node = SCNNode()
        node.position = .init(-1, 1, -1)
        node.geometry = moon
        return node
    }
    
    private func createDiceNode() -> SCNNode {
        guard let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn") else { return .init() }
        guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else { return .init() }
        diceNode.position = .init(0, 0, -0.1)
        return diceNode
    }
}
