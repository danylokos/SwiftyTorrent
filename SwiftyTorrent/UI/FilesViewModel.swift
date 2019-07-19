//
//  FilesViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/16/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import Foundation

struct FilesViewModel {
    
    var directory: Direcctory
    
    var title: String {
        get {
            return directory.name
        }
    }

}
