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
    
    var directory: Directory { get }

}

extension Directory: FilesViewModel {
    
    var title: String {
        return name
    }
    
    var directory: Directory {
        return self
    }
    
}
