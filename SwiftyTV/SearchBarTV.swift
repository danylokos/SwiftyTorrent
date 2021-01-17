//
//  SearchBarTV.swift
//  SwiftyTV
//
//  Created by Danylo Kostyshyn on 03.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI

struct SearchBarTV: UIViewControllerRepresentable {
    
    @Binding var text: String
    let placeholder: String?

    typealias UIViewControllerType = UISearchContainerViewController

    typealias Context = UIViewControllerRepresentableContext<SearchBarTV>
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let controller = UISearchController(searchResultsController: context.coordinator)
        controller.searchResultsUpdater = context.coordinator
        controller.searchBar.placeholder = placeholder
        return UISearchContainerViewController(searchController: controller)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        uiViewController.searchController.searchBar.text = text
    }

    func makeCoordinator() -> SearchBarTV.Coordinator {
        return Coordinator(text: $text)
    }

    class Coordinator: UIViewController {
        
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }

}

extension SearchBarTV.Coordinator: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        text = searchText
    }

}

