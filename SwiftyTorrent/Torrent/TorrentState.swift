//
//  TorrentState.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/26/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import Foundation

extension Torrent.State : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .checkingFiles: return "CheckingFiles"
        case .downloadingMetadata: return "DownloadingMetadata"
        case .downloading: return "Downloading"
        case .finished: return "Finished"
        case .seeding: return "Seeding"
        case .allocating: return "Allocating"
        case .checkingResumeData: return "CheckingResumeData"
        @unknown default: return "Unknown"
        }
    }

    public var symbol: String {
        switch self {
        case .downloading: return "↓"
        case .seeding: return "↑"
        default: return "*"
        }
    }

    
}
