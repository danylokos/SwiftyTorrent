//
//  Torrent.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/15/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI

extension Torrent : Identifiable {
    
    public var id: Data {
        get {
            infoHash
        }
    }
    
}
