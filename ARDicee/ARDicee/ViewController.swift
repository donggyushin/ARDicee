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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: sceneView)
        guard let query = sceneView.raycastQuery(from: location, allowing: .existingPlaneInfinite, alignment: .horizontal) else { return }
        guard let result = sceneView.session.raycast(query).first else { return }
        viewModel.touchDetected(result: result)
    }
    
    private func configureUI() {
        view.addSubview(sceneView)
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.delegate = self
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        sceneView.autoenablesDefaultLighting = true
    }
    
    private func bind(viewModel: ViewModel) {
        viewModel.viewDidLoad()
        
        viewModel.$alertMessage.compactMap({ $0 }).sink { [weak self] alertMessage in
            let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(yes)
            self?.present(alert, animated: true)
        }.store(in: &viewModel.subscriber)
        
        viewModel.$moonNode.compactMap({ $0 }).sink { [weak self] moon in
            self?.addNode(moon)
        }.store(in: &viewModel.subscriber)
        
        viewModel.$diceNode.compactMap({ $0 }).sink { [weak self] dice in
            self?.addNode(dice)
            let x = CGFloat(arc4random_uniform(4) + 1) * CGFloat(Float.pi/2)
            let z = CGFloat(arc4random_uniform(4) + 1) * CGFloat(Float.pi/2)
            dice.runAction(.rotateBy(x: x, y: 0, z: z, duration: 0.5))
        }.store(in: &viewModel.subscriber)
    }
    
    private func addNode(_ node: SCNNode) {
        sceneView.scene.rootNode.addChildNode(node)
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            viewModel.planeAnchorDetected(planeAnchor: planeAnchor, node: node )
        }
    }
}
