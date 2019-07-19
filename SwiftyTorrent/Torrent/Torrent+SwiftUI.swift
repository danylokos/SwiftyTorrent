//
//  Torrent.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/15/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI

extension Torrent : Identifiable {
    
    private static var filesCache = [Data: [FileEntry]]()
    private static var dirsCache = [Data: Direcctory]()
    
    public var id: Data {
        get {
            infoHash
        }
    }

    var fileEntries: [FileEntry] {
        get {
            if Torrent.filesCache[infoHash] == nil {
                Torrent.filesCache[infoHash] = TorrentManager.shared().filesForTorrent(withHash: infoHash)
            }
            return Torrent.filesCache[infoHash]!
        }
    }

    var directory: Direcctory {
        get {
            if Torrent.dirsCache[infoHash] == nil {
                let paths = fileEntries.map({ $0.path })
                let dir = Direcctory.directory(from: paths)
               Torrent.dirsCache[infoHash] = dir
            }
            return Torrent.dirsCache[infoHash]!
        }
    }

}
