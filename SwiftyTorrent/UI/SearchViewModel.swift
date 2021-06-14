//
//  SearchViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 29.06.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import Combine
import SwiftUI
import TorrentKit

final class SearchViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var data = [SearchDataItem]()
    
    private var imdbProvider = IMDBDataProvider.shared
    private var eztbProvider = EZTVDataProvider.shared
    private var torrentManager = TorrentManager.shared()
    
    private var cancellables = [AnyCancellable]()
    
    init() {
        $searchText
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .map {
                self.imdbProvider.fetchSuggestions($0)
                    .replaceError(with: "")
            }
            .switchToLatest()
            .map {
                self.eztbProvider.fetchTorrents(imdbId: $0)
                    .replaceError(with: [])
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { data in
                self.data = data
            })
            .store(in: &cancellables)

        // Clear results if `searchText` is empty
        $searchText
            .filter { $0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.data = []
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: -

    func select(_ item: SearchDataItem) {
        let magnetURI = MagnetURI(magnetURI: item.magnetURL)
        torrentManager.add(magnetURI)
    }
    
}
