//
//  ListViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 06.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine

protocol ListViewModelProtocol {
    var title: String { get }
    var icon: UIImage? { get }
//    var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode { get }
    
    var sections: [SectionProtocol] { get }
    var sectionsPublisher: AnyPublisher<[SectionProtocol], Never>? { get }
    var rowPublisher: AnyPublisher<(RowProtocol, IndexPath), Never>? { get }
    
    func removeItem(at indexPath: IndexPath)
//    func contextMenuConfig(at indexPath: IndexPath) -> UIContextMenuConfiguration?
    
    func start()
}

protocol SectionProtocol {
    var id: String { get }
    var title: String? { get }
    var rows: [RowProtocol] { get }
}

typealias RowAction = () -> Void

enum RowType {
    case plain
    case button(RowAction)
    case navigation(RowAction)
}

protocol RowProtocol {
    var id: String { get }
    var viewType: UITableViewCell.Type { get }
    var rowType: RowType { get }
    var action: RowAction? { get }
}

extension ListViewModelProtocol {
    
    func row(at indexPath: IndexPath) -> RowProtocol? {
        guard sections.count > indexPath.section,
            sections[indexPath.section].rows.count > indexPath.row
            else { return nil }
        return sections[indexPath.section].rows[indexPath.row]
    }
    
}

final class ListViewModel: ListViewModelProtocol {
    
    var title: String { "List" }
    var icon: UIImage? { UIImage(systemName: "list.dash") }
//    var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode { .automatic }
    
    struct Section: SectionProtocol {
        var id: String
        var title: String?
        var rows: [RowProtocol]
    }
    
    struct Row: RowProtocol {
        var id: String
        var viewType: UITableViewCell.Type { ListCell.self }
        var title: String?
        var subtitle: String?
        var rowType = RowType.plain

        var action: RowAction? {
            switch rowType {
            case .plain: return nil
            case .button(let action): return action
            case .navigation(let action): return action
            }
        }
    }

    var sections: [SectionProtocol]
    var sectionsPublisher: AnyPublisher<[SectionProtocol], Never>?
    var rowPublisher: AnyPublisher<(RowProtocol, IndexPath), Never>?
    
    init(sections: [SectionProtocol]) {
        self.sections = sections
    }
    
    func start() { }
    
    func removeItem(at indexPath: IndexPath) { }
    
//    func contextMenuConfig(at indexPath: IndexPath) -> UIContextMenuConfiguration? { return nil }

}

extension ListViewModel.Section: Equatable & Hashable {
    
    static func == (lhs: ListViewModel.Section, rhs: ListViewModel.Section) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension ListViewModel.Row: Equatable & Hashable {

    static func == (lhs: ListViewModel.Row, rhs: ListViewModel.Row) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

extension ListCell: ViewModelConfigurable {
    
    typealias ViewModel = ListViewModel.Row
    
    func configure(_ viewModel: ListViewModel.Row) {
        titleLabel.text = viewModel.title
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = viewModel.subtitle
        switch viewModel.rowType {
        case .plain:
            selectionStyle = .none
            accessoryType = .none
            titleLabel.textColor = .black
            subtitleLabel.textColor = .lightGray
            titleLabel.font = .preferredFont(forTextStyle: .headline)
            subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        case .button:
            selectionStyle = .default
            accessoryType = .none
            titleLabel.textColor = tintColor
            subtitleLabel.textColor = tintColor
            titleLabel.font = .preferredFont(forTextStyle: .body)
            subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        case .navigation:
            selectionStyle = .default
            accessoryType = .disclosureIndicator
            titleLabel.textColor = .black
            subtitleLabel.textColor = .lightGray
            titleLabel.font = .preferredFont(forTextStyle: .headline)
            subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        }
    }
    
}

extension ListCell: AnyViewModelConfigurable { }

extension ListViewModel {
    
    static func testModel() -> ListViewModel {
        return ListViewModel(sections: [
            Section(id: "sec0", title: "Section A", rows: [
                Row(id: "row0", title: "AAA", subtitle: "aaa", rowType: .button({ print("Hello, World!") })),
                Row(id: "row1", title: "BBB", subtitle: "bbb"),
                Row(id: "row2", title: "CCC", subtitle: "ccc")
            ]),
            Section(id: "sec1", title: "Section X", rows: [
                Row(id: "row0", title: "XXX", subtitle: "xxx"),
                Row(id: "row1", title: "YYY", subtitle: "yyy"),
                Row(id: "row2", title: "ZZZ", subtitle: "zzz")
            ])
        ])
    }
    
}
