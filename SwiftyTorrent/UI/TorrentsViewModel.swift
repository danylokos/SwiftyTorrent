//
//  BindableTorrentManager.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/12/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import Combine
import SwiftUI
import TorrentKit

final class TorrentsViewModel: NSObject, ObservableObject, TorrentManagerDelegate {
    
    private var torrentManager = TorrentManager.shared()

    private(set) var torrents = [Torrent]()

    private let torrentsWillChangeSubject = PassthroughSubject<Void, Never>()
    
    var objectWillChange: AnyPublisher<Void, Never> {
        torrentsWillChangeSubject
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    @Published private(set) var activeError: Error?
    
    var isPresentingAlert: Binding<Bool> {
        return Binding<Bool>(get: {
            return self.activeError != nil
        }, set: { newValue in
            guard !newValue else { return }
            self.activeError = nil
        })
    }
    
    override init() {
        super.init()
        torrentsWillChangeSubject.send()
        torrents = torrentManager.torrents()
            .sorted(by: { $0.name < $1.name })
        torrentManager.addDelegate(self)
    }
    
    func remove(_ torrent: Torrent, deleteFiles: Bool = false) {
        if let idx = torrents.firstIndex(where: { $0.infoHash == torrent.infoHash }) {
            torrentsWillChangeSubject.send()
            torrents.remove(at: idx)
        }
        torrentManager.removeTorrent(withInfoHash: torrent.infoHash, deleteFiles: deleteFiles)        
    }
    
    // MARK: - TorrentManagerDelegate
    
    func torrentManager(_ manager: TorrentManager, didAdd torrent: Torrent) {
        torrentsWillChangeSubject.send()
        torrents.append(torrent)
        torrents.sort(by: { $0.name < $1.name })
    }
    
    func torrentManager(_ manager: TorrentManager, didRemoveTorrentWithHash hashData: Data) {
        if let idx = torrents.firstIndex(where: { $0.infoHash == hashData }) {
            torrentsWillChangeSubject.send()
            torrents.remove(at: idx)
        }
    }
    
    func torrentManager(_ manager: TorrentManager, didReceiveUpdateFor torrent: Torrent) {
        if let idx = torrents.firstIndex(where: { $0.infoHash == torrent.infoHash }) {
            torrentsWillChangeSubject.send()
            torrents.remove(at: idx)
            torrents.insert(torrent, at: idx)
        }
    }
    
    func torrentManager(_ manager: TorrentManager, didErrorOccur error: Error) {
        DispatchQueue.main.async {
            self.activeError = error
        }
    }
    
}

#if DEBUG
extension TorrentsViewModel {

    func addTestTorrentFiles() {
        torrentManager.add(TorrentFile.test_1())
        torrentManager.add(TorrentFile.test_2())
    }
    
    func addTestMagnetLinks() {
        torrentManager.add(MagnetURI.test_1())
    }
    
    func addTestTorrents() {
        addTestTorrentFiles()
        addTestMagnetLinks()
    }
    
}
#endif
