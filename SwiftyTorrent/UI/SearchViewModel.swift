//
//  SearchViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 07.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine

final class SearchViewModel: NSObject, ListViewModelProtocol {
    
    var title: String { "Search" }
    var icon: UIImage? { UIImage(systemName: "magnifyingglass") }
    
    var sections: [Section]
    
    var sectionsPublisher: AnyPublisher<[Section], Never>?
    var rowPublisher: AnyPublisher<(Row, IndexPath), Never>?

    var presenter: ControllerPresenter?

    // MARK: -
    
    private var imdbProvider = IMDBDataProvider.shared
    private var eztbProvider = EZTVDataProvider.shared

    internal var cancellables = [AnyCancellable]()
    
    private var data = [SearchDataItem]()
    
    internal let searchBarTextSubject = PassthroughSubject<String, Never>()
    var searchBarTextPublisher: AnyPublisher<String, Never> { searchBarTextSubject.eraseToAnyPublisher() }
    
    // MARK: -
    
    override init() {
        sections = []
    }
    
    func start() {
        
    }

    func removeItem(at indexPath: IndexPath) {
        
    }
    
    // MARK: -
    
    func fetchData(_ searchQuery: String, completion: @escaping ([SearchDataItem]) -> Void) {
        imdbProvider
            .fetchSuggestions(searchQuery)
            .flatMap({ (value) -> AnyPublisher<[SearchDataItem], Error> in
                self.eztbProvider.fetchTorrents(imdbId: value)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print("error: \(error)")
                    completion([])
                }
            }, receiveValue: { (response) in
                completion(response)
            })
            .store(in: &cancellables)
    }
    
}

extension SearchViewModel {
    
    func bind(_ searchController: UISearchController) {
        searchBarTextPublisher
            .compactMap({ $0 })
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink(receiveValue: { searchText in
                self.fetchData(searchText) { data in
                    let section = Section(
                        title: "Results",
                        rows: data.map({
                            Row(id: UUID().uuidString, title: $0.title, subtitle: $0.size, rowType: .plain)
                        })
                    )
                    //swiftlint:disable force_cast
                    let resultsController = searchController.searchResultsController as! ListViewController
                    let listVM = resultsController.viewModel as! ListViewModel
                    listVM.sections = [section]
                    resultsController.update(with: listVM.sections)
                }
            })
            .store(in: &cancellables)
    }
    
}

extension SearchViewModel: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        searchBarTextSubject.send(searchController.searchBar.text ?? "")
    }

}
