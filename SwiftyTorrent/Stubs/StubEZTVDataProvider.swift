//
//  StubEZTVDataProvider.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 18.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import Combine

struct StubSearchDataItem: SearchDataItem {
    
    static var idx = 0
    
    var id: String
    var title: String
    var sizeBytes: UInt64
    var episodeInfo: String?
    var peersStatus: String
    var magnetURL: URL
    
    static func randomStub() -> Self {
        defer { Self.idx += 1 }
        return StubSearchDataItem(
            id: UUID().uuidString,
            title: "Stub search item (\(Self.idx))",
            sizeBytes: UInt64.random(in: 0..<(2<<40)),
            episodeInfo: "s01e01",
            peersStatus: "seeds: 2, peers: 2",
            magnetURL: URL(string: "magnet:?xt=magnet.test")!
        )
    }
}

class StubEZTVDataProvider: EZTVDataProviderProtocol {
    
    func fetchTorrents(imdbId: String, page: Int) -> AnyPublisher<[SearchDataItem], Error> {
        let items = (0..<10).map { _ in StubSearchDataItem.randomStub() }
        return Just(items)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}
