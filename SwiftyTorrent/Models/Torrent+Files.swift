//
//  Torrent.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/15/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import TorrentKit

extension Torrent {
    
    private static var filesCache = [Data: [FileEntry]]()
    private static var dirsCache = [Data: Directory]()
    
    var fileEntries: [FileEntry] {
        if Torrent.filesCache[infoHash] == nil {
            Torrent.filesCache[infoHash] = TorrentManager.shared().filesForTorrent(withHash: infoHash)
        }
        return Torrent.filesCache[infoHash]!
    }

    var directory: Directory {
        if Torrent.dirsCache[infoHash] == nil {
            let paths = fileEntries.map({ $0.path })
            let dir = Directory.directory(from: paths)
           Torrent.dirsCache[infoHash] = dir
        }
        return Torrent.dirsCache[infoHash]!
    }

}
