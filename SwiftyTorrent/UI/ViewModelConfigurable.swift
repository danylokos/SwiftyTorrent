//
//  ViewModelConfigurable.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 06.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import UIKit

protocol ViewModelConfigurable {
    
    associatedtype ViewModel = Any
    
    func configure(_ viewModel: ViewModel)
    
}

protocol AnyViewModelConfigurable {

    func configure(_ anyViewModel: Any)
    
}

extension AnyViewModelConfigurable where Self: ViewModelConfigurable {
    
    func configure(_ anyViewModel: Any) {
        guard let viewModel = anyViewModel as? ViewModel
            else { fatalError("Can't configure view of type \(type(of: self)) with model \(anyViewModel)") }
        configure(viewModel)
    }
    
}
