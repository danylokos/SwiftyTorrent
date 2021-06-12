//
//  ListViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 06.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine

struct ContextAction {
    let title: String
    let icon: UIImage?
    let isDestructive: Bool
    let handler: () -> Void

    func makeUIAction() -> UIAction {
        UIAction(
            title: title, image: icon,
            attributes: isDestructive ? [.destructive] : [],
            state: .off
        ) { _ in handler() }
    }
    
    func makeUIAlertAction() -> UIAlertAction {
        UIAlertAction(
            title: title,
            style: isDestructive ? .destructive : .default
        ) { _ in handler() }
    }

}

protocol ListViewModelProtocol {
    var title: String { get }
    var icon: UIImage? { get }
    
    var sections: [Section] { get }
    
    var sectionsPublisher: AnyPublisher<[Section], Never>? { get }
    var rowPublisher: AnyPublisher<(Row, IndexPath), Never>? { get }
    
    func removeItem(at indexPath: IndexPath)
    
    var presenter: ControllerPresenter? { get set }
    
    func contextActions(at indexPath: IndexPath) -> [ContextAction]
    
    func start()
}

extension ListViewModelProtocol {
    
    func row(at indexPath: IndexPath) -> Row? {
        guard sections.count > indexPath.section,
            sections[indexPath.section].rows.count > indexPath.row
            else { return nil }
        return sections[indexPath.section].rows[indexPath.row]
    }
    
}

// MARK: - 

class ListViewModel: ListViewModelProtocol {
    
    var title: String { "List" }
    var icon: UIImage? { UIImage(systemName: "list.dash") }

    var sections: [Section]
    
    var sectionsPublisher: AnyPublisher<[Section], Never>?
    var rowPublisher: AnyPublisher<(Row, IndexPath), Never>?
    
    func removeItem(at indexPath: IndexPath) { }
    
    var presenter: ControllerPresenter?
    
    func contextActions(at indexPath: IndexPath) -> [ContextAction] { [] }
    
    // MARK: -
    
    init(sections: [Section]) {
        self.sections = sections
    }
    
    func start() { }

}

extension ListViewModel {
    
    static func testModel() -> ListViewModel {
        return ListViewModel(sections: [
            Section(title: "Section A", rows: [
                Row(id: "row0", title: "AAA", subtitle: "aaa", rowType: .button({ print("Hello, World!") })),
                Row(id: "row1", title: "BBB", subtitle: "bbb"),
                Row(id: "row2", title: "CCC", subtitle: "ccc")
            ]),
            Section(title: "Section X", rows: [
                Row(id: "row0", title: "XXX", subtitle: "xxx"),
                Row(id: "row1", title: "YYY", subtitle: "yyy"),
                Row(id: "row2", title: "ZZZ", subtitle: "zzz")
            ])
        ])
    }
    
}
