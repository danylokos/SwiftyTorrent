//
//  Torrent.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/15/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import TorrentKit

extension Torrent {
    
    private var torrentManager: TorrentManagerProtocol {
        resolveComponent(TorrentManagerProtocol.self)        
    }
    
    private static var filesCache = [Data: [FileEntry]]()
    private static var dirsCache = [Data: Directory]()
    
    private var fileEntries: [FileEntry] {
        if Torrent.filesCache[infoHash] == nil {
            Torrent.filesCache[infoHash] = torrentManager.filesForTorrent(withHash: infoHash)
        }
        return Torrent.filesCache[infoHash]!
    }

    var directory: Directory {
        if Torrent.dirsCache[infoHash] == nil {
            let dir = Directory.directory(from: fileEntries)
           Torrent.dirsCache[infoHash] = dir
        }
        return Torrent.dirsCache[infoHash]!
    }

}
