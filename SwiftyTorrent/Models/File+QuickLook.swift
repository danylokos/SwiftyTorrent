//
//  File+QuickLook.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 02.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import QuickLook
import TorrentKit

extension File: QLPreviewItem {
    
    public var previewItemURL: URL? {
        return TorrentManager.shared().downloadsDirectoryURL()
            .appendingPathComponent(path)
    }
    
    public var previewItemTitle: String? {
        return title
    }
    
}
