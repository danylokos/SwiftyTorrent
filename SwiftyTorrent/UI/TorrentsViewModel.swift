//
//  BindableTorrentManager.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/12/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine
import TorrentKit

final class TorrentsViewModel: NSObject, ListViewModelProtocol, TorrentManagerDelegate {

    var title: String { "Downloads" }
    var icon: UIImage? { UIImage(systemName: "arrow.up.arrow.down") }

    var sections = [Section]() {
        didSet {
            sectionsSubject.send(sections)
        }
    }

    private let sectionsSubject = PassthroughSubject<[Section], Never>()
    var sectionsPublisher: AnyPublisher<[Section], Never>? {
        sectionsSubject
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private let rowSubject = PassthroughSubject<(Row, IndexPath), Never>()
    var rowPublisher: AnyPublisher<(Row, IndexPath), Never>? {
        rowSubject
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    var presenter: ControllerPresenter?
    
    func contextActions(at indexPath: IndexPath) -> [ContextAction] {
        return [
            ContextAction(
                title: "Remove torrent",
                icon: UIImage(systemName: "trash"),
                isDestructive: true) {
                self.removeItem(at: indexPath)
            },
            ContextAction(
                title: "Remove all data",
                icon: UIImage(systemName: "trash"),
                isDestructive: true) {
                self.removeAllData(at: indexPath)
            }
        ]
    }
    
    // MARK: -
    
    private var torrentManager = TorrentManager.shared()
    private var torrents = [Torrent]()

    var activeError: Error?
        
    func start() {
        torrentManager.addDelegate(self)
        torrents = torrentManager.torrents()
        sections = createSections(from: torrents)
    }
    
    func removeItem(at indexPath: IndexPath) {
        let torrent = torrents[indexPath.row]
        torrentManager.removeTorrent(withInfoHash: torrent.infoHash, deleteFiles: false)
    }
    
    func removeAllData(at indexPath: IndexPath) {
        let torrent = torrents[indexPath.row]
        torrentManager.removeTorrent(withInfoHash: torrent.infoHash, deleteFiles: true)
    }

    // MARK: - TorrentManagerDelegate
    
    func torrentManager(_ manager: TorrentManager, didAdd torrent: Torrent) {
        torrents = torrentManager.torrents()
        sections = createSections(from: torrents)
    }
    
    func torrentManager(_ manager: TorrentManager, didRemoveTorrentWithHash hashData: Data) {
        torrents = torrentManager.torrents()
        sections = createSections(from: torrents)
    }

    func torrentManager(_ manager: TorrentManager, didReceiveUpdateFor torrent: Torrent) {
        if let idx = torrents.firstIndex(where: { $0.infoHash == torrent.infoHash }) {
            let vm = Row(torrent: torrent)
            let indexPath = IndexPath(row: idx, section: 0)
            rowSubject.send((vm, indexPath))
        }
    }
    
    func torrentManager(_ manager: TorrentManager, didErrorOccur error: Error) {
        activeError = error
    }
    
    // MARK: -
    
    private func createSections(from torrents: [Torrent]) -> [Section] {
        var sections = [Section]()
        sections.append(
            Section(id: "torrents", title: "Torrents", rows: torrents.map { torrent in
                Row(torrent: torrent, action: {
                    let filesVM = FilesViewModel(directory: torrent.directory)
                    filesVM.presenter = self.presenter
                    let controller = ListViewController(viewModel: filesVM)
                    self.presenter?.push(controller)
                })
            })
        )
        #if DEBUG && targetEnvironment(simulator)
        sections.append(
            Section(id: "debug", title: "Debug", rows: [
                Row(id: "row0", title: "Add test torrent files", subtitle: nil,
                    rowType: .button({ self.addTestTorrentFiles() })),
                Row(id: "row1", title: "Add test magnet links", subtitle: nil,
                    rowType: .button({ self.addTestMagnetLinks() })),
                Row(id: "row2", title: "Add all test torrents", subtitle: nil,
                    rowType: .button({ self.addTestTorrents() }))
            ])
        )
        #endif
        return sections
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

extension Row {
    
    private static var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()

    init(torrent: Torrent, action: RowAction? = nil) {
        self.id = torrent.infoHashString()
        self.title = torrent.name
    
        let progressString = String(format: "%0.2f %%", torrent.progress * 100)
        let statusDetails = "\(torrent.state.symbol) \(torrent.state), \(progressString), " +
            "seeds: \(torrent.numberOfSeeds), peers: \(torrent.numberOfPeers)"

        let downloadRateString = Self.byteCountFormatter.string(fromByteCount: Int64(torrent.downloadRate))
        let uploadRateString = Self.byteCountFormatter.string(fromByteCount: Int64(torrent.uploadRate))
        let connectionDetails = "↓ \(downloadRateString), ↑ \(uploadRateString)"
        
        self.subtitle = statusDetails + "\n" + connectionDetails
        if let action = action {
            self.rowType = .navigation(action)
        }
    }
    
}
