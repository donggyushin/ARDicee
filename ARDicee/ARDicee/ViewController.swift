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
    
    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.text = "Shake your device to roll the dices"
        return view
    }()
    
    private lazy var rollButton: UIButton = {
        let view = UIButton(configuration: .filled(), primaryAction: .init(handler: { _ in
            self.viewModel.rollButtonTapped()
        }))
        view.setTitle("ROLL", for: .normal)
        return view
    }()
    
    private lazy var clearButton: UIButton = {
        let view = UIButton(configuration: .filled(), primaryAction: .init(handler: { _ in
            self.viewModel.clearButtonTapped()
        }))
        view.tintColor = .systemRed
        view.setTitle("CLEAR", for: .normal)
        return view
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [rollButton, clearButton])
        view.axis = .vertical
        view.spacing = 12
        return view
    }()
    
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
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        viewModel.deviceShaked()
    }
    
    private func configureUI() {
        view.addSubview(sceneView)
        view.addSubview(verticalStackView)
        view.addSubview(descriptionLabel)
        
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            verticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50),
            verticalStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50),
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
            viewModel.diceGenerated(dice)
        }.store(in: &viewModel.subscriber)
        
        viewModel.$dices.sink { [weak self] dices in
            let isHidden = dices.isEmpty
            self?.rollButton.isHidden = isHidden
            self?.descriptionLabel.isHidden = isHidden
            self?.clearButton.isHidden = isHidden
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
