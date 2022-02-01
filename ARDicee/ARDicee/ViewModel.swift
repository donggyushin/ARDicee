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

            // Run the view's session
            sceneView.session.run(configuration)
        } else {
            self.alertMessage = "Your device is not available for AR World Tracking Service. Sorry for inconvenience"
        }
    }
    
    func viewWillDisappear(sceneView: ARSCNView) {
        sceneView.session.pause()
    }
}
