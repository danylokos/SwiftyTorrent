//
//  FileRowModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/16/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import TorrentKit

protocol FileRowModel {
    
    var title: String { get }
    
//    var pathDetails: String { get }
//
//    var sizeDetails: String { get }
    
}

extension FileEntry: FileRowModel {
    
    var title: String {
        return name
    }
    
    var pathDetails: String {
        return path
    }
    
    var sizeDetails: String {
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
}
