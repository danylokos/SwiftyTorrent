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
    
    private let torrentManager = resolveComponent(TorrentManagerProtocol.self)

    private(set) var torrents = [Torrent]()

    private let torrentsWillChangeSubject = PassthroughSubject<Void, Never>()

    var objectWillChange: AnyPublisher<Void, Never>

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
        objectWillChange = torrentsWillChangeSubject
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        super.init()
        torrentManager.addDelegate(self)
        reloadData()
    }
    
    func reloadData() {
        torrentsWillChangeSubject.send()
        torrents = torrentManager.torrents()
            .sorted(by: { $0.name < $1.name })
    }
    
    func remove(_ torrent: Torrent, deleteFiles: Bool = false) {
        torrentManager.removeTorrent(withInfoHash: torrent.infoHash, deleteFiles: deleteFiles)
    }
    
    func pauseTorrent(_ torrent: Torrent) {
        torrentManager.pauseTorrent(withInfoHash: torrent.infoHash)
    }
    
    func resumeTorrent(_ torrent: Torrent) {
        torrentManager.resumeTorrent(withInfoHash: torrent.infoHash)
    }
    
    // MARK: - TorrentManagerDelegate
    
    func torrentManager(_ manager: TorrentManager, didAdd torrent: Torrent) {
        reloadData()
    }
    
    func torrentManager(_ manager: TorrentManager, didRemoveTorrentWithHash hashData: Data) {
        reloadData()
    }
    
    func torrentManager(_ manager: TorrentManager, didReceiveUpdateFor torrent: Torrent) {
        reloadData()
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
