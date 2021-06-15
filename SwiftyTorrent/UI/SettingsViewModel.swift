//
//  SettingsViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 15.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import TorrentKit

final class SettingsViewModel: ObservableObject {
    
    @Published var availableDiskSpace: String = "N\\A"
    @Published var usedDiskSpace: String = "N\\A"
    
    @Published var eztvEndpoint: String = EZTVDataProvider.endpoint
    
    @Published var appVersion: String = {
        guard
            let infoDict = Bundle.main.infoDictionary,
            let appVer = infoDict["CFBundleShortVersionString"] as? String,
            let buildVer = infoDict["CFBundleVersion"] as? String
        else { return "N\\A" }
        return "\(appVer) (\(buildVer))"
    }()
        
    private let torrentManager = TorrentManager.shared()
    
    init() {
        availableDiskSpace = calcAvailableDiskSpace()
        usedDiskSpace = calcUsedDiskSpace()
    }
    
    // MARK: -
    
    private func calcAvailableDiskSpace() -> String {
        let downloadsURL = torrentManager.downloadsDirectoryURL()
        guard
            let attrs = try? FileManager.default.attributesOfFileSystem(forPath: downloadsURL.path),
            let value = attrs[.systemFreeSize] as? NSNumber
        else { return "N\\A" }
        return ByteCountFormatter.string(fromByteCount: value.int64Value, countStyle: .file)
    }
    
    private func calcUsedDiskSpace() -> String {
        let downloadsURL = torrentManager.downloadsDirectoryURL()
        guard
            let subpaths = try? FileManager.default.subpathsOfDirectory(atPath: downloadsURL.path)
        else { return "N\\A" }

        var totalSize: Int64 = 0
        for fileName in subpaths {
            guard
                let attrs = try? FileManager.default.attributesOfItem(
                    atPath: downloadsURL.appendingPathComponent(fileName).path
                ),
                let value = attrs[.size] as? NSNumber
            else { continue }
            totalSize += value.int64Value
        }
        return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    
    // MARK: -
    
    func reloadData() {
        availableDiskSpace = calcAvailableDiskSpace()
        usedDiskSpace = calcUsedDiskSpace()
    }
    
    func removeAllDownloads() {
        defer {
            availableDiskSpace = calcAvailableDiskSpace()
            usedDiskSpace = calcUsedDiskSpace()
        }
        
        // Remove all torrents
        torrentManager.removeAllTorrents(withFiles: true)
        
        // Remove file leftovers
        let downloadsURL = torrentManager.downloadsDirectoryURL()
        guard
            let contents = try? FileManager.default.contentsOfDirectory(
                at: downloadsURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
        else { return }
        for fileURL in contents {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch let error {
                print(error)
            }
        }
    }
    
}
