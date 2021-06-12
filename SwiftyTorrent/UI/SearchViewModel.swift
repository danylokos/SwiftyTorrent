//
//  SearchViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 07.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine
import TorrentKit

final class SearchViewModel: NSObject, ListViewModelProtocol {
    
    var title: String { "Search" }
    var icon: UIImage? { UIImage(systemName: "magnifyingglass") }
    
    var sections: [Section]
    
    var sectionsPublisher: AnyPublisher<[Section], Never>?
    var rowPublisher: AnyPublisher<(Row, IndexPath), Never>?

    var presenter: ControllerPresenter?
    
    func contextActions(at indexPath: IndexPath) -> [ContextAction] { [] }

    // MARK: -
    
    private var imdbProvider = IMDBDataProvider.shared
    private var eztbProvider = EZTVDataProvider.shared

    internal var cancellables = [AnyCancellable]()
    
    private var data = [SearchDataItem]()
    
    internal let searchBarTextSubject = PassthroughSubject<String?, Never>()
    var searchBarTextPublisher: AnyPublisher<String?, Never> { searchBarTextSubject.eraseToAnyPublisher() }
    
    // MARK: -
    
    override init() {
        sections = []
    }
    
    func start() { }

    func removeItem(at indexPath: IndexPath) { }
    
}

extension SearchViewModel {
    
    func bind(_ searchController: UISearchController) {
        searchBarTextPublisher
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
                guard
                    let resultsController = searchController.searchResultsController as? ListViewController,
                    let listVM = resultsController.viewModel as? ListViewModel
                else { return }

                let section = Section(id: "results", title: "Results", rows: data.map { item in
                    Row(id: item.id, title: item.title,
                        subtitle: item.details, rowType: .plain {
                            let magnet = MagnetURI(magnetURI: item.magnetURL)
                            TorrentManager.shared().add(magnet)
                        })
                })

                listVM.sections = [section]
                resultsController.update(with: listVM.sections)
            })
            .store(in: &cancellables)
    }
    
}

extension SearchViewModel: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        searchBarTextSubject.send(searchController.searchBar.text)
    }

}
