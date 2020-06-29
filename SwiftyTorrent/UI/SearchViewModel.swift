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
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .filter({ !$0.isEmpty })
            .sink(receiveValue: { value in
                print("value: \(value)")
                self.fetchData(value)
            })
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }

    private func fetchData(_ searchQuery: String) {
        imdbProvider
            .fetchSuggestions(searchQuery)
            .flatMap({ (value) -> AnyPublisher<[SearchDataItem], Error> in
                self.eztbProvider.fetchTorrents(imdbId: value)
            })
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print("error: \(error)")
                    self.data = []
                }
            }, receiveValue: { (response) in
                self.data = response
            })
            .store(in: &cancellables)
    }
    
    func select(_ item: SearchDataItem) {
        let magnetURI = MagnetURI(magnetURI: item.magnetURL)
        torrentManager.add(magnetURI)
    }
        
}
