//
//  ViewController.swift
//  ARDicee
//
//  Created by 신동규 on 2022/02/01.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    struct Dependency {
        let viewModel: ViewModel
    }
    
    init(dependency: Dependency) {
        viewModel = dependency.viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = .init()
        super.init(coder: coder)
    }
    
    let sceneView: ARSCNView = .init()
    private let viewModel: ViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind(viewModel: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillApear(sceneView: sceneView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.viewWillDisappear(sceneView: sceneView)
    }
    
    private func configureUI() {
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        addNode(sceneView, createDiceNode())
        sceneView.autoenablesDefaultLighting = true 
    }
    
    private func bind(viewModel: ViewModel) {
        viewModel.$alertMessage.compactMap({ $0 }).sink { [weak self] alertMessage in
            let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(yes)
            self?.present(alert, animated: true)
        }.store(in: &viewModel.subscriber)
    }
    
    private func createDiceNode() -> SCNNode {
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        cube.materials = [material]
        let node = SCNNode()
        node.position = .init(0, 0, -0.5)
        node.geometry = cube
        return node
    }
    
    private func addNode(_ sceneView: ARSCNView, _ node: SCNNode) {
        sceneView.scene.rootNode.addChildNode(node)
    }
}
