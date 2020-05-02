//
//  FilesViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/16/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import Foundation

protocol FilesViewModel {
    
    var title: String { get }
    
    var directory: Direcctory { get }

}

extension Direcctory: FilesViewModel {
    
    var title: String {
        return name
    }
    
    var directory: Direcctory {
        return self
    }
    
}
