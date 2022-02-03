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
    @Published var moonNode: MoonNode?
    @Published var diceNode: SCNNode?
    @Published var dices: [SCNNode] = []
    
    var subscriber: Set<AnyCancellable> = .init()
    
    func viewDidLoad() {
        self.moonNode = createMoonNode()
    }
    
    func viewWillApear(sceneView: ARSCNView) {
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]
            sceneView.session.run(configuration)
        } else {
            self.alertMessage = "Your device is not available for AR World Tracking Service. Sorry for inconvenience"
        }
    }
    
    func diceGenerated(_ dice: SCNNode) {
        roll(dice)
        dices.append(dice)
    }
    
    func rollButtonTapped() {
        rollAllDices()
    }
    
    func deviceShaked() {
        rollAllDices()
    }
    
    func clearButtonTapped() {
        dices.forEach({ $0.removeFromParentNode() })
        dices = []
    }
    
    private func rollAllDices() {
        dices.forEach({ roll($0) })
    }
    
    func viewWillDisappear(sceneView: ARSCNView) {
        sceneView.session.pause()
    }
    
    func planeAnchorDetected(planeAnchor: ARPlaneAnchor, node: SCNNode) {
        
        let extentPlane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let extentNode = SCNNode(geometry: extentPlane)
        let gridMaterial = SCNMaterial()
        
        extentNode.simdPosition = planeAnchor.center
        extentNode.eulerAngles.x = -.pi / 2
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        extentPlane.materials = [gridMaterial]
        node.addChildNode(extentNode)
    }
    
    func touchDetected(result: ARRaycastResult) {
        let dice = createDiceNode(result: result)
        self.diceNode = dice
    }
    
    private func createMoonNode() -> MoonNode {
        let moon = SCNSphere(radius: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpeg")
        moon.materials = [material]
        let node = MoonNode()
        node.position = .init(-1, 1, -1)
        node.geometry = moon
        return node
    }
    
    private func createDiceNode(result: ARRaycastResult) -> SCNNode {
        guard let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn") else { return .init() }
        guard let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) else { return .init() }
        let column3 = result.worldTransform.columns.3
        diceNode.position = .init(column3.x, column3.y, column3.z)
        return diceNode
    }
    
    private func roll(_ dice: SCNNode) {
        let x = CGFloat(arc4random_uniform(4) + 1) * CGFloat(Float.pi/2)
        let z = CGFloat(arc4random_uniform(4) + 1) * CGFloat(Float.pi/2)
        dice.runAction(.rotateBy(x: x, y: 0, z: z, duration: 0.5))
    }
}
