//
//  Torrent+Cell.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/12/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import TorrentKit

protocol TorrentRowModel {
    
    var title: String { get }
    
    var statusDetails: String { get }
    
    var connectionDetails: String { get }
    
}

extension Torrent: TorrentRowModel {

    var title: String {
        return name
    }
    
    var statusDetails: String {
        let progressString = String(format: "%0.2f %%", progress * 100)
        return "\(state.symbol) \(state), \(progressString), seeds: \(numberOfSeeds), peers: \(numberOfPeers)"
    }
    
    var connectionDetails: String {
        let downloadRateString = ByteCountFormatter.string(fromByteCount: Int64(downloadRate), countStyle: .binary)
        let uploadRateString = ByteCountFormatter.string(fromByteCount: Int64(uploadRate), countStyle: .binary)
        return "↓ \(downloadRateString), ↑ \(uploadRateString)"
    }

}
