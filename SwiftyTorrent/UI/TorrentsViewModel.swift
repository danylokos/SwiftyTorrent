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
    
    private let updateSubject = PassthroughSubject<Void, Never>()
    
    typealias PublisherType = AnyPublisher<Void, Never>
    
    let objectWillChange: PublisherType
    
    @Published var torrents: [Torrent]! {
        willSet {
            updateSubject.send()
        }
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
        objectWillChange = updateSubject
            .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        super.init()
        TorrentManager.shared().addDelegate(self)
    }
    
    func addTestTorrentFiles() {
        TorrentManager.shared().add(TorrentFile.test_1())
        TorrentManager.shared().add(TorrentFile.test_2())
    }
    
    func addTestMagnetLinks() {
        TorrentManager.shared().add(MagnetURI.test_1())
    }
    
    func addTestTorrents() {
        addTestTorrentFiles()
        addTestMagnetLinks()
    }
    
    func remove(_ torrent: Torrent) {
        TorrentManager.shared().remove(torrent.infoHash)
    }
    
    // MARK: - TorrentManagerDelegate
    
    func torrentManagerDidReceiveUpdate(_ manager: TorrentManager) {
        torrents = manager.torrents().sorted(by: { $0.name < $1.name })
    }
    
    func torrentManager(_ manager: TorrentManager, didErrorOccur error: Error) {
        activeError = error
    }
    
}
