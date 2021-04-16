//
//  SearchProvider.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 08.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine

class SearchProvider: NSObject {

    func makeSearchController() -> (SearchViewModel, UIViewController) {
        let searchVM = SearchViewModel()
        let resultsController = ListViewController(viewModel: ListViewModel(sections: []))
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = searchVM
        searchController.searchBar.autocapitalizationType = .none
        searchVM.bind(searchController)
        #if os(iOS)
        let searchVC = ListViewController(viewModel: searchVM)
        searchVC.navigationItem.searchController = searchController
        searchVC.navigationItem.hidesSearchBarWhenScrolling = false
        searchVC.definesPresentationContext = true
        return (searchVM, searchVC)
        #elseif os(tvOS)
        let searchVC = UISearchContainerViewController(searchController: searchController)
        searchVC.title = searchVM.title
        searchVC.tabBarItem.title = searchVM.title
        searchVC.tabBarItem.image = searchVM.icon
        return (searchVM, searchVC)
        #endif
    }

}
