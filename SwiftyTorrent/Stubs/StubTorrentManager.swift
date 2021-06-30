//
//  StubTorrentManager.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 18.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import TorrentKit

class StubTorrentManager: TorrentManagerProtocol {
    
    var isSessionActive = true

    func addDelegate(_ delegate: TorrentManagerDelegate) { }
    
    func removeDelegate(_ delegate: TorrentManagerDelegate) { }
    
    func restoreSession() { }
    
    func add(_ torrent: STDownloadable) -> Bool { true }
    
    func removeTorrent(withInfoHash infoHash: Data, deleteFiles: Bool) -> Bool { true }
    
    func removeAllTorrents(withFiles deleteFiles: Bool) -> Bool { true }
    
    func torrents() -> [Torrent] { (0..<10).map { _ in Torrent.randomStub() } }
    
    func open(_ URL: URL) { }
    
    func filesForTorrent(withHash infoHash: Data) -> [FileEntry] { [] }
    
    func downloadsDirectoryURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())        
    }

}
