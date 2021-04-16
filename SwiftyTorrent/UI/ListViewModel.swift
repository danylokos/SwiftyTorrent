//
//  ListViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 06.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine

typealias RowAction = () -> Void

enum RowType {
    case plain
    case button(RowAction)
    case navigation(RowAction)
}

struct Section: Hashable {
    var id = UUID()
    var title: String?
    var rows: [Row]
}

struct Row: Equatable, Hashable {
    var id: String
    var viewType: UITableViewCell.Type { ListCell.self }
    var title: String?
    var subtitle: String?
    var rowType: RowType = .plain

    var action: RowAction? {
        switch rowType {
        case .plain: return nil
        case .button(let action): return action
        case .navigation(let action): return action
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.id == rhs.id
    }

}

// MARK: -

protocol ListViewModelProtocol {
    var title: String { get }
    var icon: UIImage? { get }
    
    var sections: [Section] { get }
    
    var sectionsPublisher: AnyPublisher<[Section], Never>? { get }
    var rowPublisher: AnyPublisher<(Row, IndexPath), Never>? { get }
    
    func removeItem(at indexPath: IndexPath)
    
    var presenter: ControllerPresenter? { get set }
    
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
