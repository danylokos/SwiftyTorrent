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

final class TorrentsViewModel: NSObject, ListViewModelProtocol, TorrentManagerDelegate {
    
    var title: String { "Downloads" }
    var icon: UIImage? { UIImage(systemName: "arrow.up.arrow.down") }

    var sections = [SectionProtocol]() {
        didSet {
            sectionsSubject.send(sections)
        }
    }

    private let sectionsSubject = PassthroughSubject<[SectionProtocol], Never>()
    var sectionsPublisher: AnyPublisher<[SectionProtocol], Never>?

    private let rowSubject = PassthroughSubject<(RowProtocol, IndexPath), Never>()
    var rowPublisher: AnyPublisher<(RowProtocol, IndexPath), Never>?

    private var torrentManager = TorrentManager.shared()
    private var torrents = [Torrent]()
    
    var activeError: Error?

    override init() {
        sectionsPublisher = sectionsSubject
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        rowPublisher = rowSubject
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        super.init()
    }
    
    func start() {
        torrentManager.addDelegate(self)
        torrents = torrentManager.torrents()
        sections = createSections(from: torrents)
    }
    
    func remove(_ torrent: Torrent) {
        torrentManager.remove(torrent.infoHash)        
    }
    
    func removeItem(at indexPath: IndexPath) {
        let torrent = torrents[indexPath.row]
        remove(torrent)
    }
    
    func contextMenuConfig(at indexPath: IndexPath) -> UIContextMenuConfiguration? {
        if sections[indexPath.section].id == "sec0" {
            let delete = UIAction(
                title: "Delete", image: UIImage(systemName: "trash"),
                attributes: [.destructive]) { _ in
                    self.removeItem(at: indexPath)
            }
            let deleteData = UIAction(
                title: "Delete All Data", image: UIImage(systemName: "trash"),
                attributes: [.destructive]) { _ in
                    self.removeItem(at: indexPath)
            }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                UIMenu(title: "Actions", children: [delete, deleteData])
            }
        }
        return nil
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
        if let idx = self.torrents.firstIndex(where: { $0.infoHash == torrent.infoHash }) {
            let vm = ListViewModel.Row(torrent: torrent)
            let indexPath = IndexPath(row: idx, section: 0)
            rowSubject.send((vm, indexPath))
        }
    }
    
    func torrentManager(_ manager: TorrentManager, didErrorOccur error: Error) {
        activeError = error
    }
    
    // MARK: -
    
    private func createSections(from torrents: [Torrent]) -> [ListViewModel.Section] {
        var sections = [ListViewModel.Section]()
        sections.append(
            ListViewModel.Section(id: "sec0", title: "Torrents", rows: torrents.map { ListViewModel.Row(torrent: $0) })
        )
        #if DEBUG
        sections.append(
            ListViewModel.Section(id: "sec1", title: "Debug", rows: [
                ListViewModel.Row(id: "row0", title: "Add test torrent files", subtitle: nil,
                                  rowType: .button({ self.addTestTorrentFiles() })),
                ListViewModel.Row(id: "row1", title: "Add test magnet links", subtitle: nil,
                                  rowType: .button({ self.addTestMagnetLinks() })),
                ListViewModel.Row(id: "row2", title: "Add all test torrents", subtitle: nil,
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

extension ListViewModel.Row {
    
    private static var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()

    init(torrent: Torrent) {
        self.id = torrent.infoHashString()
        self.title = torrent.name
    
        let progressString = String(format: "%0.2f %%", torrent.progress * 100)
        let statusDetails = "\(torrent.state.symbol) \(torrent.state), \(progressString), " +
            "seeds: \(torrent.numberOfSeeds), peers: \(torrent.numberOfPeers)"

        let downloadRateString = Self.byteCountFormatter.string(fromByteCount: Int64(torrent.downloadRate))
        let uploadRateString = Self.byteCountFormatter.string(fromByteCount: Int64(torrent.uploadRate))
        let connectionDetails = "↓ \(downloadRateString), ↑ \(uploadRateString)"
        
        self.subtitle = statusDetails + "\n" + connectionDetails
    }
    
}
