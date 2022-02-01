//
//  CompositionRoot.swift
//  ARDicee
//
//  Created by 신동규 on 2022/02/01.
//

struct AppDependency {
    let viewControllerFactory: (ViewModel) -> ViewController
}

extension AppDependency {
    static func resolve() -> AppDependency {
        
        let viewControllerFactory: (ViewModel) -> ViewController = { viewModel in
            return .init(dependency: .init(viewModel: viewModel))
        }
        
        return .init(viewControllerFactory: viewControllerFactory)
    }
}
