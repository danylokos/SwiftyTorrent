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
    @Published var isLoading: Bool = false
    @Published var items = [SearchDataItem]()
    
    private var currentPage = 1
    private var hasMorePages = false
    
    private let imdbProvider = resolveComponent(IMDBDataProviderProtocol.self)
    private let eztbProvider = resolveComponent(EZTVDataProviderProtocol.self)
    private let torrentManager = resolveComponent(TorrentManagerProtocol.self)
    
    private var cancellables = [AnyCancellable]()
    
    init() {
        $searchText
            .handleEvents(receiveOutput: { text in
                // Clear results if `searchText` is empty
                if text.isEmpty {
                    self.items = []
                }
            })
            .filter { !$0.isEmpty }
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .handleEvents(receiveOutput: { _ in
                self.isLoading = true
                self.currentPage = 1
                self.hasMorePages = true
            })
            .map {
                self.imdbProvider.fetchSuggestions($0)
                    .replaceError(with: "")
            }
            .switchToLatest()
            .map {
                self.eztbProvider.fetchTorrents(imdbId: $0, page: 1)
                    .replaceError(with: [])
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { _ in
                self.isLoading = false
            })
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: -

    func loadMoreIfNeeded(currentItem item: SearchDataItem) {
        let thresholdIdx = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.id == item.id }) == thresholdIdx {
            loadMore()
        }
    }
    
    private func loadMore() {
        guard !isLoading && hasMorePages else { return }

        isLoading = true
        
        imdbProvider.fetchSuggestions(searchText)
            .map {
                self.eztbProvider.fetchTorrents(imdbId: $0, page: self.currentPage + 1)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { items in
                self.isLoading = false
                self.currentPage += 1
                self.hasMorePages = !items.isEmpty
            })
            .map { items in
                return self.items + items
            }
            .catch({ _ in Just(self.items) })
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
    }
    
    func select(_ item: SearchDataItem) {
        let magnetURI = MagnetURI(magnetURI: item.magnetURL)
        torrentManager.add(magnetURI)
    }
    
}
