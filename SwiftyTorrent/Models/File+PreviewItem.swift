//
//  File+PreviewItem.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 02.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import MediaKit
import TorrentKit

extension File: PreviewItem {
    
    private var torrentManager: TorrentManagerProtocol {
        resolveComponent(TorrentManagerProtocol.self)
    }
    
    public var previewItemURL: URL? {
        return torrentManager
            .downloadsDirectoryURL()
            .appendingPathComponent(path)
    }
    
    public var previewItemTitle: String? {
        return title
    }
    
}
